# Blender

Blender is a modular remote command execution framework. It can discover nodes
and run a commands against them. Blender allows cross node workflows to be expressed
in plain ruby DSL and invoked on demand using command line interface, or scheduled
periodically using Rufus scheduler.

Following is an example of a simple blender usage, where a
task(command "echo HelloWorld" here) is executed locally.

```ruby
task "echo HelloWorld"
```

```sh
blend_it -f example.rb
```
```sh
Run[example.rb] started
 1 job(s) computed using 'Default' strategy
  Job 1 [echo HelloWorld on localhost] finished
Run finished (0.03382832 s)
```

Iternally, blender create a shell task, and executes the task using shell out driver
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

  * Discoveries - or host discovery, Search and dicover nodes that can be assigned globally, or
 against individual tasks (e.g. chef discovery)
  * Drivers - Drivers are the component that actually execute the commands
(or equivalent abstraction) against local or remote hosts (e.g. ssh driver)
  * Scheduling stratgy: or the order of execution. This determines the exact
order of task executions aginst a group of hosts.

### Task & Driver

Tasks and drivers compliment each other. Tasks act as front end, where we declare
what needs to be done, while driver are used to interprete how those tasks can be done (backends).
For example `ssh_task` can be used to declare tasks, while `ssh` and `ssh_multi` driver
can execute `ssh_task`s. Currently blender ships with following tasks and drivers:

  - shell_task: execute commands on current host. shell tasks can only have 'localhost'
  as the members. presence of any other hosts in members list will raise exception. shell_tasks
  are executed using shell_out driver (used Mixlib::ShellOut internally).
  Example:
  ```ruby
  shell_task 'foo' do
    execute 'sudo apt-get update -y'
  end
  ```

  - ruby_task: execute ruby blocks against current host. host names from members list is passed
  to the block. ruby_tasks are executed using Blender::Ruby driver.
  Example:
  ```ruby
  ruby_task 'baz' do
    execute do |host|
      puts  "Host name is: #{host}"
    end
  end
  ```

  - ssh_task: execute commands against remote hosts using ssh. Blender ships with two ssh drivers,
  one based vaniall ruby net-ssh binding, another based on net-ssh-multi (which supports parallel
  execution)
  Example:
  ```ruby
  ssh_task 'bar' do
    execute 'sudo apt-get update -y'
    members ['host1', 'host2']
  end
  ```

  - serf_task: execute serf queris against remote hosts. Blnder ships with two serf drivers, one for
  fire & forget style serf queries which is used for fast/quick tasks, another one for long running
  tasks which involves fire and poll periodically till completion, called as async_serf driver, which is
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

Drivers are can be shared across tasks. When blender bootsup it assigns a default `shell_out` driver.
Each tasks, when created checks for the default driver, and used it if its compatible, else creates a new
one. Drivers can be created explicitly and assigned to tasks directly as well. Following are the relevent driver
related API:
  - Define the global/default driver explicitly
  ```ruby
  global_driver
  ```
``

## Host discovery

  - serf: discover hosts using serf membership
  - chef: discover hosts using Chef search

### Job

### Scheduling Strategies

  - default strategy
  - per host strategy
  - per task strategy

### Invoking blender periodially with Rufus schedler

### Ignore failure, parallel job execution

### Event handlers

## Contributing

1. Fork it ( https://github.com/PagerDuty/blender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
