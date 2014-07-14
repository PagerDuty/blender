require 'net/ssh'
require 'blender/exceptions'
require 'blender/drivers/base'
require 'chef/monkey_patches/net-ssh-multi'

module Blender
  module Driver
    class SshMulti < Base

      def execute(job)
        tasks = job.tasks
        hosts = job.hosts
        Log.debug("SSH execution tasks [#{tasks.inspect}]")
        Log.debug("SSH on hosts [#{hosts.inspect}]")
        @session = ssh_multi_session(hosts)
        Array(tasks).each do |task|
          if evaluate_guards?(task)
            Log.debug("Task:#{task.name}| Guards are valid")
          else
            Log.debug("Task:#{task.name}| Guards are invalid")
            run_task_command(task)
          end
        end
        @session.loop
      end

      def run_task_command(task)
         e_status = raw_exec(task.command).exitstatus
         if e_status != 0
           if task.metadata[:ignore_failure]
             Log.warn('Ignore failure is set, skipping failure')
           else
            raise Exceptions::ExecutionFailed, "Failed to execute '#{task.command}'"
           end
         end
      end

      def raw_exec(command)
        password = @config[:password]
        command = fixup_sudo(command)
        exit_status = 0
        stdout = config[:stdout] || File.open(File::NULL, 'w')
        stderr = config[:stderr] || File.open(File::NULL, 'w')
        channel = @session.open_channel do |ch|
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

      private

      def fixup_sudo(command)
        command.sub(/^sudo/, 'sudo -p \'blender sudo password: \'')
      end

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
          concurrent_connections: 5,
          on_error: error_handler
        )
        hosts.each do |h|
          s.use(user + '@' + h)
        end
        s
      end
    end
  end
end
