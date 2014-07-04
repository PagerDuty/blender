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
        sch.instance_eval(des)
      end
    end

    desc 'daemon', 'Run blender in daemon mode'
    method_option :schedule,
      default: 'Schedule_it',
      type: :string,
      aliases: '-s'
    def daemon
      sched = Blender::Timer.new
      des = File.read(options[:schedule])
      sched.instance_eval(des)
      sched.join
    end
  end
end
