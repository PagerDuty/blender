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
(host1, host2 and host3) will be assumed.

A blender script can have multiple types of tasks as well (shell, ssh, raw ruby etc).

Blender is composed of three major sub-components, these are:

  * Discoveries - or host discovery, Search and dicover nodes that can be assigned globally, or
 against individual tasks (e.g. chef discovery)
  * Drivers - Drivers are the component that actually execute the commands
(or equivalent abstraction) against local or remote hosts (e.g. ssh driver)
  * Scheduling stratgy: or the order of execution. This determines the exact
order of task executions aginst a group of hosts.

## Task & Driver

In Blender, tasks and drivers compliment each other. Tasks act as front end, to declare
what needs to be done, while driver are used to interprete how those tasks can be done (backends).
For example `ssh_task` can be used to declare tasks, while `ssh` and `ssh_multi` driver
can execute `ssh_task`s. Currently blender ships with following tasks and drivers:

### Tasks

  - shell_task: execute commands on current host
  - ruby_task: execute ruby blocks against current host
  - ssh_task: execute commands against remote hosts using ssh
  - serf_task: execut serf queris against remote hosts

### Drivers

  - shell_out
  - ruby
  - ssh
  - ssh multi
  - serf
  - async_serf


## Host discovery

  - serf: discover hosts using serf membership
  - chef: discover hosts using Chef search

### Job

### Strategies

  - default strategy
  - per host strategy
  - per task strategy

## Scheduling blender scripts with rufus scheduler


## Ignore failure, parallel job execution


## Contributing

1. Fork it ( https://github.com/PagerDuty/blender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
