# Blender

Blender is a modular remote command execution framework. It can discover nodes
and run a commands against them. Blender allows cross node workflows to be expressed
in plain ruby DSL and execute them 'on demand' using command line interface, or scheduled
periodically using Rufus scheduler, or from arbitrary ruby code/apps.

Following is an example of a simple blender script, where a
task is executed locally.

Script:
```ruby
task "echo HelloWorld"
```
Execute it like this:
```sh
blend -f example.rb
```
```sh
Run[example.rb] started
 1 job(s) computed using 'Default' strategy
  Job 1 [echo HelloWorld on localhost] finished
Run finished (0.03382832 s)
```

Under the hood, Blender creates a shell task, and executes the task using shell out driver
against localhost. In the next example, we are defining a single task to be run against
3 hosts over ssh.

```ruby
members ['host1.example.com', 'host2.example.com', 'host3.example.com']

ssh_task "check ip address" do
  execute "ifconfig -a"
end
```
You can define multiple tasks, and individual tasks can declare their own
target hosts, like this:

```ruby
members ['host1.example.com', 'host2.example.com', 'host3.example.com']

ssh_task "check ip address" do
  execute "ifconfig -a"
end

ssh_task "check load average" do
  execute "w"
  members ['host2.example.com', 'host3.example.com']
end

ssh_task "check memory" do
  execute "free -m"
  members ['host5.example.com']
end
```

If a task does not declare its own memebers (i.e. target hosts), global members
(host1, host2 and host3) will be assumed. A blender script can have multiple
tasks of differenet types.

## Concepts

Blender is composed of three major sub-components, these are:

  * **Discoveries** - Responsible for host discovery. Blender tasks have members
  associated with them. This can be a hardcoded list of hosts, but for dynamic
  infrastructure, you can search and dicover nodes that can be assigned globally,
  or against individual tasks.

  * **Tasks and Drivers** - Taska encapsulated commands(or equivalent abstraction). A blender
  script can have a series of tasks. Drivers execute the commands (defined
  inside tasks), against local or remote hosts (e.g. ssh driver). Individual task
  types can only be run with a compatible set of drivers. Some of the task types has more
  than one drivers.

  * **Scheduling stratgy** - Logic that determines the order of command execution. This include
  the order of hosts as well in a distributed workflow. Scheduling strategy takes the workflow
  description as input and produces a list of jobs (to be executed using drivers).

### Task & Driver

Tasks and drivers compliment each other. Tasks act as front end, where we declare
what needs to be done, while drivers used to interprete how those tasks can be done (backends).
For example `ssh_task` can be used to declare tasks, while `ssh` and `ssh_multi` driver
can execute `ssh_task`s. Currently blender ships with following tasks and drivers:

  - **shell_task**: execute commands on current host. shell tasks can only have 'localhost'
  as the members. presence of any other hosts in members list will raise exception. shell_tasks
  are executed using shell_out driver (used Mixlib::ShellOut internally).
  Example:
  ```ruby
  shell_task 'foo' do
    execute 'sudo apt-get update -y'
  end
  ```

  - **ruby_task**: execute ruby blocks against current host. host names from members list is passed
  to the block. ruby_tasks are executed using Blender::Ruby driver.
  Example:
  ```ruby
  ruby_task 'baz' do
    execute do |host|
      puts  "Host name is: #{host}"
    end
  end
  ```

  - **ssh_task**: execute commands against remote hosts using ssh. Blender ships with two ssh drivers,
  one based vaniall ruby net-ssh binding, another based on net-ssh-multi (which supports parallel
  execution)
  Example:
  ```ruby
  ssh_task 'bar' do
    execute 'sudo apt-get update -y'
    members ['host1', 'host2']
  end
  ```

  - **serf_task**: execute serf queris against remote hosts. Blnder ships with two serf drivers, one for
  fire & forget style serf queries which is used for fast/quick tasks, another one for long running
  tasks which involves fire and poll periodically till completion,  called as async_serf driver, which is
  based on the Serfx::AsyncJob module.

  Exmample of a simple serf task:
  ```ruby
  serf_task 'test' do
    query 'metadata'
    payload 'ipaddress'
    timeout 4
    members ['host1', 'host2']
  end
  ```

Whenever a new task is declared blender look for a compatible driver. Unless a driver is explicitly specified,
Blender will try its best to reuse the global driver if compatible, else it will create one. By default the
global_driver is a shell_out driver. You can define different global_driver using the dsl, and it will affect
any tasks defined afterwards. This allows us to customize the driver behavior (like concurrency, stdout sharing
etc).
Following is an example of specifyng the global_driver as ssh, with stdout streaming.

  ```ruby
  global_driver(:ssh, stdout: $stdout, password: ask('SSH pass: '))

  ssh_task 'run chef' do
    execute 'sudo chef-client --no-fork'
    members Array.new(100){|n| "host-#{n}"}
  end
  ```
Other drivers can also be regiseterd and reused across tasks, using the dsl.

   ```ruby
  # register a serf driver (type), with name `awesome`
  register_driver(:serf, 'awesome', authkey: 'FOOBAR')
  serf_task 'chef' do
    payload 'start'
    use_driver 'awesome'
  end
  ```

## Host discovery

Blender allows discovering hosts dynamically. It ships with chef and serf based host
discoveries. Discovery dsl can be consumed globally to define a host list, or per task.
Following are some examples:

  - **serf**: discover hosts using serf membership
  ```ruby
  ruby_task 'print host name' do
    execute do |host|
      Blender::Log.info("Host: #{host}")
    end
    members serf_nodes(name: 'web-.*')
  end
  ```
  - **chef**: discover hosts using Chef search
  ruby_task 'print host name' do
    execute do |host|
      Blender::Log.info("Host: #{host}")
    end
    members chef_nodes(search: 'roles:web')
  end
  ```
Discovery specific dsl methods can take additional options to specify configuration options.
Like `node_name` and `client_key` for chef. Defaults for those can also be specified using
`init` dsl method.

```ruby
init(:chef, client_key: '/path/to/client.pem', node_name: 'foobar')
```
will instruct all chef_nodes call to use these default configs. Same applies for serf based
discovery.


### Scheduling strategies and Job

Scheduling strategies are perhaps logically most crucial part of blender. They decide the
order of command execution across distributed nodes in blender. Each blender script is invoked using one strategy. Consider them as a transformation, where the input is tasks and ouput is
jobs. Tasks and job are pretty similar in their structures (both holds command and hosts),
except a jobs can hold multiple tasks within them. We'll come to this later, but first, lets
see how the default strategy work.
  - **default strategy**: the default strategy takes the list of declared tasks (and associated members in each tasks) breaks them up into per node jobs. For example:
  ```ruby
  members ['host1', 'host2', 'host3']

  ruby_task 'test' do
    execute do |host|
      Blender::Log.info(host)
    end
  end
  ```
will result in 3 jobs. each with ruby_task[test] on host1, ruby_task[test] on host2  and
ruby_task[test] on host3. And then these three tasks will be executed serially.
Following will create 6 jobs.
  ```ruby
  members ['host1', 'host2', 'host3']

  ruby_task 'test 1' do
    execute do |host|
      Blender::Log.info("test 1 on #{host}")
    end
  end

  ruby_task 'test 2' do
    execute do |host|
      Blender::Log.info("test 2 on #{host}")
    end
  end
  ```
While the next one will create 5 jobs (second task will give only one job).

  ```ruby
  members ['host1', 'host2', 'host3']

  ruby_task 'test 1' do
    execute do |host|
      Blender::Log.info("test 1 on #{host}")
    end
  end

  ruby_task 'test 2' do
    execute do |host|
      Blender::Log.info("test 2 on #{host}")
    end
    members ['host3']
  end
  ```
The default strategy is conservative, and allows drivers that work against a single remote
host to be integrated with blender. Also this allows the highest level of fine grain job control.

Apart from the default strategy, Blender ships with two more strategy, they are:
  - **per task strategy**: this creates one job per task. Following example will create 2 jobs, each with three hosts and one of the ruby_task in them.

  ```ruby
  members ['host1', 'host2', 'host3']

  strategy :per_task

  ruby_task 'test 1' do
    execute do |host|
      Blender::Log.info("test 1 on #{host}")
    end
  end

  ruby_task 'test 2' do
    execute do |host|
      Blender::Log.info("test 2 on #{host}")
    end
  end
  ```
per task strategy allows drivers to optimize individual command execution accross multiple hosts. For
example ssh_multi driver allows parallel command execution across many hosts. And can be used
as:
  ```ruby
  strategy :per_task
  global_driver(:ssh_multi, concurrency: 50)
  ssh_task 'run chef' do
    execute 'sudo chef-client --no-fork'
  end
  ```
  Note: if we use the default strategy, ssh_multi driver wont be able to leverage its
  concurrency  features, as the resultant jobs (the driver will receive) will have only one host.

  - **per host strategy**: it creates one job per host. Following example will create 3 jobs. each with one host and 2 ruby tasks. Thus two tasks will be executed in one host, then on the next one.. follow on. Think of deployments with rolling restart like scenarios. This also allows drivers
to optimize multiple tasks/commandsi execution against individual hosts (session reuse etc).

  ```ruby
  strategy :per_host
  members ['host1', 'host2', 'host3']

  ruby_task 'test 1' do
    execute do |host|
      Blender::Log.info("test 1 on #{host}")
    end
  end
  ruby_task 'test 2' do
    execute do |host|
      Blender::Log.info("test 2 on #{host}")
    end
  end
  ```
Note: this strategy does not work if you have different hosts per tasks.

Its fairly easy to write custom scheduling strategies and they can be used to rewrite or
rearrange hosts/tasks as you wish. For example, null strategy that return 0 jobs irrespective
of what tasks or members you pass, or a custome strategy that takes the hosts lists of every tasks and considers only one of them dynamicaaly based on some metrics for jobs.. etc.

### Invoking blender periodially with Rufus schedler

Blender is designed to be used as a standalone script that can be invoked on-demand or
consumed as a library, i.e. workflows are written in plain ruby objects and invoked
from other tools or application. Apart from these, Blender can be use for periodic
job execution also. Underneath it uses Rufus::Scheduler to trigger Blender run, after
a fixed interval (can be expressed via cron syntax as well, thanks to Rufus).

Following will run `example.rb` blender script after every 4 hours.
```ruby
schedule '/path/to/example.rb' do
  cron '* */4 * * *'
end
```

### Ignore failure, parallel job execution

Blender will fail the execution immediately if any of the job fails. `ignore_failure` attribute can be used to proceed execution even after failure. This can be declared both per task level as well as globally.
  ```ruby
  shell_task 'fail' do
    command 'ls /does/not/exists'
    ignore_failure true
  end
  shell_task 'will be executed' do
    command 'echo "Thrust is what we need"'
  end
  ```

Blender can parallelize job execution in two ways. Via the drivers (like serf, ssh_multi etc) or via the global `concurrent` dsl method which uses a minimal thread pool implementation. Note, the global concurrency dsl method work as job level, and when used jobs are executed in paralle batches as opposed to serial. 

### Event handlers

Blende provides an event disptachment facility (inspired from Chef), where arbitrary logic can
be hooked into the event system (e.g hipchat notification handlers, statsd handlers etc) and blender will automatically invoke them during key events. As of now, events are available before and after run and per job execution. Event dispatch system is likely to get more elaborate and Blender might have few common event handlers(metric, notifications etc) in near future.

## License
[Apache 2](http://www.apache.org/licenses/LICENSE-2.0)

## Contributing

1. Fork it ( https://github.com/PagerDuty/blender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
