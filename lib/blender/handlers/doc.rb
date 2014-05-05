require 'blender/utils/ui'

module Blender
  module Handlers
    class Doc < Base

      attr_reader :ui

      def initialize
        @ui = Blender::Utils::UI.new
      end

      def run_started(scheduler)
        @start_time = Time.now
        @task_id = 0
        @job_id = 1
        ui.puts_cyan("Run[#{scheduler.name}] started")
      end

      def run_finished(scheduler)
        delta = ( Time.now - @start_time)
        ui.puts_cyan("Run finished (#{delta} s)")
      end

      def job_started(job)
      end

      def job_finished(job)
        ui.puts_green("  #{job.to_s} finished")
      end

      def job_errored(job, e)
        ui.puts_red("  #{job.to_s} errored")
      end

      def job_computation_started(strategy)
        @compute_start_time = Time.now
        @strategy = strategy.class.name.split('::').last
      end

      def job_computation_finished(scheduler, jobs)
        delta = Time.now - @compute_start_time
        ui.puts_cyan(" #{jobs.size} subtasks computed using '#{@strategy}' strategy")
      end

      def skipping_for_why_run(desc)
        ui.puts_green(desc)
      end
    end
  end
end
