module Blender
  class ScheduledJob
    attr_reader :schedule
    def initialize(name)
      @name = name
      @file = nil
    end

    def blender_file(file)
      @file = file
    end

    def cron(line)
      @schedule = [ __method__, line]
    end

    def every(*args)
      @schedule = [ __method__, args]
    end

    def run
      des = File.read(@file)
      Blender.blend(@file) do |sch|
        sch.instance_eval(des, __FILE__, __LINE__)
      end
    end
  end
end
