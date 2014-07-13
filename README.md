# Blender

Blender is a modular remote command execution framework. It can discover nodes
and run a series of command sequentially or parrallely against them. Blender
provides chef and serf based host discovery out of the box. Remote commands
can be executed either via ssh or as serf jobs. Blender has drivers for local
shell and ruby based jobs as well.

## Installation

    $ gem install blender

## Usage


```ruby
Blender.blend 'sudo apt-get update -y'
```

Blender can be used from arbitrary ruby scripts as a library or as a standalone
binary to execute jobs written in blender's DSL.



## Contributing

1. Fork it ( https://github.com/[my-github-username]/blender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
