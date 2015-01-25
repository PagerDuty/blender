members ['h1', 'h2', 'h3']

ruby_task 'task2' do
  execute do |h|
    puts 'HelloWorld'
  end
end
shell_task 'task3' do
  execute 'does not exist'
  ignore_failure true
end
