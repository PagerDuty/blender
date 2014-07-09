require 'thor'
require 'blender'
require 'blender/timer'

module Blender
  class CLI < Thor

    default_command :from_file
    package_name 'Blender'

    desc 'from_file ', 'Run blender job from a file'
    method_option :file,
      default: 'Blend_it',
      type: :string,
      aliases: '-f'
    def from_file
      des = File.read(options[:file])
      Blender.blend(options[:file]) do |sch|
        sch.instance_eval(des, __FILE__, __LINE__)
      end
    end

    desc 'schedule', 'Run blender in daemon mode, with job scheduled in periodic interval'
    method_option :schedule,
      default: 'Schedule_it',
      type: :string,
      aliases: '-s'
    def schedule
      sched = Blender::Timer.new
      des = File.read(options[:schedule])
      sched.instance_eval(des)
      sched.join
    end
  end
end
