[![Built on Travis](https://secure.travis-ci.org/PagerDuty/blender.png?branch=master)](http://travis-ci.org/PagerDuty/blender)
# Blender

Blender is a modular remote command execution framework. Blender provides few basic
primitives to automate cross server workflows. Workflows can be expressed in plain
ruby DSL and executed using the CLI.

Following is an example of a simple blender script that will update the package
index of three ubuntu servers.

```ruby
# example.rb
ssh_task 'update' do
  execute 'sudo apt-get update -y'
  members ['ubuntu01', 'ubuntu02', 'ubuntu03']
end
```

Which can execute it as:
```sh
blend -f example.rb
```
Output:
```
Run[example.rb] started
 3 job(s) computed using 'Default' strategy
  Job 1 [update on ubuntu01] finished
  Job 2 [update on ubuntu02] finished
  Job 3 [update on ubuntu03] finished
Run finished (42.228923876 s)
```
An workflow can have multiple tasks, individual tasks can have different members
which can be run in parallel.

```ruby
# example.rb
ssh_task 'update' do
  execute 'sudo apt-get update -y'
  members ['ubuntu01', 'ubuntu02', 'ubuntu03']
end

ssh_task 'install' do
  execute 'sudo apt-get install screen -y'
  members ['ubuntu01', 'ubuntu03']
end

concurrency 2
```
Output:
```sh
Run[blends/example.rb] started
 5 job(s) computed using 'Default' strategy
  Job 1 [update on ubuntu01] finished
  Job 2 [update on ubuntu02] finished
  Job 4 [install on ubuntu01] finished
  Job 3 [update on ubuntu03] finished
  Job 5 [install on ubuntu03] finished
Run finished (4.462043017 s)
```

Blender provides various types of task execution (like arbitrary ruby code,
commands over ssh, serf handlers etc) which can ease automating large cluster
maintenance, multi stage provisioning, establishing cross server feedback
loops etc.

## Installation

Blender is published as `pd-blender` in rubygems. And you can install it as:
```sh
gem install pd-blender
```
Or declare it as a dependency in your Gemfile, if you are using bundler.
```ruby
gem 'pd-blender'
```

## Concepts

Blender is composed of two components:

  * **Tasks and drivers** - Tasks encapsulate commands (or equivalent abstraction). A blender
  script can have multiple tasks. Tasks are executed using drivers. Tasks can declare their
  target hosts.

  * **Scheduling strategy** - Determines the order of task execution across the hosts. 
  Every blender scripts has one and only one scheduling strategy. Scheduling strategies
  uses the task list as input and produces a list of jobs, to be executed using drivers.


### Tasks

Tasks and drivers compliment each other. Tasks act as front end, where we declare
what needs to be done, while drivers are used to interpret how those tasks can be done.
For example `ssh_task` can be used to declare tasks, while `ssh` and `ssh_multi` driver
can execute `ssh_task`s. Blender core ships with following tasks and drivers:

  - **shell_task**: execute commands on current host. shell tasks can only have 'localhost'
  as its members. presence of any other hosts in members list will raise exception. shell_tasks
  are executed using shell_out driver.
  Example:
  ```ruby
  shell_task 'foo' do
    execute 'sudo apt-get update -y'
  end
  ```

  - **ruby_task**: execute ruby blocks against current host. host names from members list is passed
  to the block. ruby_tasks are executed using `Blender::Ruby` driver.
  Example:
  ```ruby
  ruby_task 'baz' do
    execute do |host|
      puts "Host name is: #{host}"
    end
  end
  ```

  - **ssh_task**: execute commands against remote hosts using ssh. Blender ships with two ssh drivers,
  one based on a vanilla Ruby `net-ssh` binding, another based on `net-ssh-multi` (which supports parallel
  execution)
  Example:
  ```ruby
  ssh_task 'bar' do
    execute 'sudo apt-get update -y'
    members ['host1', 'host2']
  end
  ```

As mentioned earlier tasks are executed using drivers. Tasks can declare their preferred driver or
Blender will assign a driver to them automatically. Blender will reuse the global driver if its
compatible, else it will create one. By default the ```global_driver``` is a ```shell_out``` driver.
Drivers can expose host concurrency, stdout/stderr streaming and various other customizations,
specific to their own implementations.

### Scheduling strategies

Scheduling strategies are the most crucial part of a blender script. They decide the
order of command execution across distributed nodes in blender. Each blender script is
 invoked using one strategy. Consider them as a transformation, where the input is tasks and ouput is
jobs. Tasks and job are pretty similar in their structures (both holds command and hosts),
except a jobs can hold multiple tasks within them. We'll come to this later, but first, lets
see how the default strategy work.

  - **default strategy**: the default strategy takes the list of declared tasks (and associated members
in each tasks) breaks them up into per node jobs.
 For example:

  ```ruby
  members ['host1', 'host2', 'host3']

  ruby_task 'test' do
    execute do |host|
      Blender::Log.info(host)
    end
  end
  ```

  will result in 3 jobs. each with `ruby_task[test]` on host1, `ruby_task[test]` on host2 and
  `ruby_task[test]` on host3. And then these three tasks will be executed serially.
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

  While the next one will create 4 jobs (second task will give only one job).

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

  - **per task strategy**: this creates one job per task. Following example will
  create 2 jobs, each with three hosts and one of the `ruby_task` in them.

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
  example `ssh_multi` driver allows parallel command execution across many hosts. And can be used
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

  - **per host strategy**: it creates one job per host. Following example will create
 3 jobs. each with one host and 2 ruby tasks. Thus two tasks will be executed in one
 host, then on the next one.. follow on. Think of deployments with rolling restart like
 scenarios. This also allows drivers to optimize multiple tasks/commandsi execution
 against individual hosts (session reuse etc).

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
of what tasks or members you pass, or a custome strategy that takes the hosts lists of every
tasks and considers only one of them dynamically based on some metrics for jobs, etc.

### Host discovery

For workflows that depends on dynamic infrastructure, where host names are changing,
Blender provides abstractions that facilitate discovering them.
[blender-chef](https://github.com/PagerDuty/blender-chef) and
[blender-serf](https://github.com/PagerDuty/blender-serf) uses this and allows remote job orchestration
for chef or serf managed infrastructure.

Following are some examples:

  - **serf**: discover hosts using serf membership

  ```ruby
  require 'blender/serf'

  ruby_task 'print host name' do
    execute do |host|
      Blender::Log.info("Host: #{host}")
    end
    members search(:serf, name: '^lt-.*$')
  end
  ```

  - **chef**: discover hosts using Chef search

  ```ruby
  require 'blender/dscoveries/chef'

  ruby_task 'print host name' do
    execute do |host|
      Blender::Log.info("Host: #{host}")
    end
    members search(:chef, 'roles:web')
  end
  ```

## Invoking blender periodially with Rufus scheduler

Blender is designed to be used as a standalone script that can be invoked on-demand or
consumed as a library, i.e. workflows are written in plain Ruby objects and invoked
from other tools or application. Apart from these, Blender can be use for periodic
job execution also. Underneath it uses `Rufus::Scheduler` to trigger Blender run, after
a fixed interval (can be expressed via cron syntax as well, thanks to Rufus).

Following will run `example.rb` blender script after every 4 hours.
  ```ruby
  schedule '/path/to/example.rb' do
    cron '* */4 * * *'
  end
  ```

## Ignore failure

Blender will fail the execution immediately if any of the job fails. `ignore_failure`
attribute can be used to proceed execution even after failure. This can be declared
both per task level as well as globally.

  ```ruby
  shell_task 'fail' do
    command 'ls /does/not/exists'
    ignore_failure true
  end
  shell_task 'will be executed' do
    command 'echo "Thrust is what we need"'
  end
  ```


## Event handlers

Blender provides an event dispatchment facility (inspired from Chef), where arbitrary logic can
be hooked into the event system (e.g. HipChat notification handlers, statsd handlers, etc) and blender
will automatically invoke them during key events. As of now, events are available before and after run
and per job execution. Event dispatch system is likely to get more elaborate and blender might havei
few common event handlers (metric, notifications etc) in near future.


## Ancillary projects

Blender has a few ancillary projects for integration with other systems, following are few of them:
- Zookeepr based locking for distributed blender deployments [blender-zk](https://github.com/PagerDuty/blender-zk)
- Serf based host discovery and command dispatch [blender-serf](https://github.com/PagerDuty/blender-serf)
- Chef based host discovery [blender-chef](https://github.com/PagerDuty/blender-chef)

## Supported ruby versions

Blender currently support the following Ruby implementations:

* *Ruby 1.9.3*
* *Ruby 2.1.0*
* *Ruby 2.1.2*

## License
[Apache 2](http://www.apache.org/licenses/LICENSE-2.0)

## Contributing

1. Fork it ( https://github.com/PagerDuty/blender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
