require_relative 'data/helper'
require 'blender'
require 'pry'


Blender::Log.level = :debug
spec = {serf: 5}
helper.chef_cluster(spec, 'recipe[serf]')
binding.pry
