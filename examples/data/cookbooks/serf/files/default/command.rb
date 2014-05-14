#!/opt/chef/embedded/bin/ruby

class SerfEvent

  attr_reader :environment, :payload, :type

  def initialize(env=ENV)
    @environment = env.keys.select{|k|k=~/^SERF/}.inject({}) do |memo, k|
      memo[k] = env[k].strip
      memo
    end
    @type = @environment['SERF_EVENT']
    if %w{query user}.include?(@type)
      begin
        @payload = STDIN.read_nonblock(4096).strip
      rescue Errno::EAGAIN => e
        @payload = nil
      end
    end
  end
end

class JobProcessor
  def initialize(opts = {})
    @state_dir = opts[:state_dir] || '/opt/serf/state'
  end

  def process(event)
    if event.payload.nil?
       print 'command is missing'
    else
      case event.type
      when 'query'
        process_query(event)
      when 'user'
        process_event(event)
      else
        print "can not process #{event.type}"
      end
    end
  end

  def process_query(event)
     type = event.environment['SERF_QUERY_NAME']
     case type
     when 'command'
      check_command(event.payload)
     else
       print "response for:'#{type}' not implementd"
     end
  end

  def check_command(command)
    pid_file = File.join(@state_dir, "#{command}_pid")
    if File.exist? pid_file
      pid = File.read(pid_file).strip
      proc_file = File.join('/etc/proc', pid)
      if File.exists? proc_file
        print 'running'
      else
        print 'stale'
      end
    else
      print 'finished'
    end
  end

  def process_event(event)
     type = event.environment['SERF_USER_EVENT']
     command = event.payload
     pid_file = File.join(@state_dir, "#{command}_pid")
     stdout_file = File.join(@state_dir, "#{command}_stdout")
     stderr_file = File.join(@state_dir, "#{command}_stderr")
     case type
     when 'command:spawn'
       pid = Process.spawn(command, out: stdout_file, err: stderr_file)
       Process.detach pid
       File.open(pid_file,'w') do |f|
         f.write(pid)
       end
     when 'command:clean'
       [ pid_file, stdout_file, stderr_file ].each do |file|
         File.unlink(file)
       end
     when 'command:kill'
       pid = File.read(pid_file).to_i
       Process.kill('KILL', pid)
       [ pid_file, stdout_file, stderr_file ].each do |file|
         File.unlink(file)
       end
     else
       print "handler for:'#{type}' not implemented"
     end
  end

  def print(value)
    STDOUT.print(value)
  end
end

if __FILE__ == $0
  JobProcessor.new.process(SerfEvent.new)
end
