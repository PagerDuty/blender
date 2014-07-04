require 'net/ssh'
require 'blender/exceptions'
require 'blender/drivers/base'

module Blender
  module Driver
    class Ruby < Base

      def execute(job)
        tasks = job.tasks
        Log.debug("RUby execution tasks [#{tasks.inspect}]")
        Array(tasks).each do |task|
          if evaluate_guards?(task)
            Log.debug('Guards are valid')
          else
            Log.debug('Guards are invalid')
            run_task_command(task)
          end
        end
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
        exit_status = 0
        stdout = ''
        stderr = ''
        begin
          command.call
        rescue Exception => e
          stderr = e.message
          exit_status = -1
        end
        ExecOutput.new(exit_status, stdout, stderr)
      end
    end
  end
end
