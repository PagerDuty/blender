require 'net/ssh'
require 'blender/exceptions'
require 'blender/drivers/ssh'
require 'chef/monkey_patches/net-ssh-multi'

module Blender
  module Driver
    class SshMulti < Ssh

      def execute(tasks, hosts)
        tasks = job.tasks
        hosts = job.hosts
        Log.debug("SSH execution tasks [#{tasks.inspect}]")
        Log.debug("SSH on hosts [#{hosts.inspect}]")
        session = ssh_multi_session(hosts)
        Array(tasks).each do |task|
          cmd = run_command(task.command, session)
          if cmd.exitstatus != 0 and !task.metadata[:ignore_failure]
            raise Exceptions::ExecutionFailed, cmd.stderr
          end
        end
        session.loop
      end

      def run_command(command, session)
        password = @config[:password]
        command = fixup_sudo(command)
        exit_status = 0
        stdout = config[:stdout] || File.open(File::NULL, 'w')
        stderr = config[:stderr] || File.open(File::NULL, 'w')
        channel = session.open_channel do |ch|
          ch.request_pty
          ch.exec(command) do |ch, success|
            unless success
              Log.debug("Command not found:#{success.inspect}")
              exit_status = -1
            end
            ch.on_data do |c, data|
              stdout << data
              if data =~ /^blender sudo password: /
                c.send_data("#{password}\n")
              end
            end
            ch.on_extended_data do |c, type, data|
              stderr << data
            end
            ch.on_request "exit-status" do |ichannel, data|
              l = data.read_long
              exit_status = [exit_status, l].max
              Log.debug("exit_status:#{exit_status} , data:#{l}")
            end
          end
          Log.debug("Exit(#{exit_status}) Command: '#{command}'")
        end
        channel.wait
        ExecOutput.new(exit_status, stdout, stderr)
      end
      def concurrency
        @config[:concurrency]
      end

      private

      def ssh_multi_session(hosts)
        user = @config[:user] || ENV['USER']
        ssh_config = { password: @config[:password]}
        error_handler = lambda do |server|
          if config[:ignore_on_failure]
            $!.backtrace.each { |l| Blender::Log.debug(l) }
          else
            throw :go, :raise
          end
        end
        s = Net::SSH::Multi.start(
          concurrent_connections: concurrency,
          on_error: error_handler
        )
        hosts.each do |h|
          s.use(user + '@' + h)
        end
        s
      end

      private

      def default_config
        super.merge(concurrency: 5)
      end
    end
  end
end
