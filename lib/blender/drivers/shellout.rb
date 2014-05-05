require 'mixlib/shellout'
require 'blender/exceptions'
require 'blender/log'
require 'blender/drivers/base'

module Blender
  module Driver
    class ShellOut < Base

      def raw_exec(command)
        cmd = Mixlib::ShellOut.new(command)
        yield cmd if block_given?
        cmd.run_command
        cmd
      end

      def stdout(stream)
        @stdout = stream
      end

      def stderr(stream)
        @stderr = stream
      end

      def execute(job)
        tasks = job.tasks
        hosts = job.hosts
        check_empty!(hosts)
        stdout = config[:stdout]
        stderr = config[:stderr]
        Array(tasks).each do |task|
          converge_by "will be executing: #{task.command.inspect}" do
            cmd = raw_exec(task.command) do |shellout|
              shellout.live_stream = stdout
            end
            if cmd.exitstatus != 0
              raise Exceptions::ExecutionFailed, cmd.stderr
            end
          end
        end
      end

      def check_empty!(hosts)
        unless Array(hosts).all?{|h|h == 'localhost'}
          raise Exceptions::UnsupportedFeature, 'ShellOut driver does not support any host other than localhost'
        end
      end
    end
  end
end
