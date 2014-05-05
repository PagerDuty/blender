module Blender
  module Handlers
    class Base
      def run_started(scheduler)
      end
      def run_finished(scheduler)
      end
      def job_computation_started(strategy)
      end
      def job_computation_finished(strategy, jobs)
      end
      def task_started(task)
      end
      def task_finished(task)
      end
      def task_skipped(task)
      end
      def task_executed(task)
      end
      def job_started(job)
      end
      def job_finished(job)
      end
      def job_errored(job, error)
      end
      def skipping_for_why_run(desc)
      end
    end
  end
end
