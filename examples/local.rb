require 'blender'

Blender.blend('echo "Hello World"')

Blender.blend('some awesome stuff') do |sch|
  sch.task 'echo "Task One"'
  sch.task 'echo "Two"'
end

Blender.blend('dont fail') do |sch|
  sch.task 'ls -alh /does/not/exist'
  sch.ignore_failure true
end

Blender.blend('concurrent tasks') do |sch|
  sch.task 'sleep 6 && echo "This will be after"'
  sch.task 'sleep 3 && echo "This will be in middle"'
  sch.task 'sleep 1 && echo "This will be before"'
  sch.concurrency 3
end

Blender.blend('concurrency with ignore failure') do |sch|
  sch.task 'sleep 6 && echo "after warning"'
  sch.task 'sleep 3 && ls xx'
  sch.task 'sleep 1 && echo "befor warning"'
  sch.concurrency 3
  sch.ignore_failure true
end

Blender.blend('guards with shellout') do |sch|
  sch.task 'echo "Checking not_if guard"'
  sch.task 'test guard' do |t|
    t.execute 'ping -c 10 8.8.8.8'
    t.not_if 'ping -c 1 8.8.8.8'
  end
  sch.task 'echo "Should be printed soon after"'
  sch.task 'ping -c 5 8.8.8.8'
  sch.task 'echo "This will be printed with some delay"'
end
