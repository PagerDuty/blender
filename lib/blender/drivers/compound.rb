module Blender
  module Driver
    class Compound
      def execute(tasks, hosts)
        hosts.each do |host|
          tasks.each do |task|
            task.driver.execute([task], [host])
          end
        end
      end
    end
  end
end
