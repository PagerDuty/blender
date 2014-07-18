module Blender
  module Driver
    class Compound
      def execute(tasks, hosts)
        tasks.each do |task|
          task.driver.execute(tasks, hosts)
        end
      end
    end
  end
end
