# Blender

Blender is a modular remote command execution framework. It can discover nodes
and run a series of command sequentially or parrallely against them. Blender
provides chef and serf based host discovery out of the box. Remote commands
can be executed either via ssh or as serf jobs. Blender has drivers for local
shell and ruby based jobs as well.

## Concepts

### Task & Driver

#### Tasks

  - shell_task: execute commands on current host
  - ruby_task: execute ruby blocks against current host
  - ssh_task: execute commands against remote hosts using ssh
  - ssh_task: execut serf queris against remote hosts

#### Drivers


### Host discovery

  - serf: discover hosts using serf membership
  - chef: discover hosts using Chef search

### Job

### Strategies

  - default strategy
  - per host strategy
  - per task strategy

## Scheduling blender scripts with rufus scheduler


Blender can be used from arbitrary ruby scripts as a library or as a standalone
binary to execute jobs written in blender's DSL.



## Contributing

1. Fork it ( https://github.com/PagerDuty/blender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
