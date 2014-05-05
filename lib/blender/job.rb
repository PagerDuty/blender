

module Blender
  class Job

    attr_reader :tasks, :hosts

    def initialize(id, name, hosts, tasks)
      @id = id
      @name = name
      @hosts = Array(hosts)
      @tasks = Array(tasks)
    end

    def to_s
      "Job[#{@name}]"
    end
  end
end
