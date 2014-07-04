require 'blender/exceptions'
require 'blender/log'
require 'blender/drivers/base'

module Blender
  module Driver
    class Local < Base
      def execute(job)
        tasks = job.tasks
        hosts = job.hosts
        verify_local_host!(hosts)
        Array(tasks).each do |task|
          converge_by "will be executing: #{task.command.inspect}" do
            cmd = raw_exec(task.command)
            if cmd.exitstatus != 0
              raise Exceptions::ExecutionFailed, cmd.stderr
            end
          end
        end
      end

      def verify_local_host!(hosts)
        unless Array(hosts).all?{|h|h == 'localhost'}
          raise Exceptions::UnsupportedFeature, 'ShellOut driver does not support any host other than localhost'
        end
      end
    end
  end
end
