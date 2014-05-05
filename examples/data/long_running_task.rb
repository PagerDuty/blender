#!/usr/bin/env ruby

file =  File.open(ARGV[0] || File::NULL, 'w')
how_long = ARGV[1] || 10

how_long.to_i.times do |n|
  sleep 1
  $stdout.puts(Time.now.to_s)
  file.puts(Time.now.to_s)
end

file.close
