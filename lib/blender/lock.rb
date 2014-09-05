#
# Author:: Ranjib Dey (<ranjib@pagerduty.com>)
# Copyright:: Copyright (c) 2014 PagerDuty, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fcntl'
require 'blender/exceptions'

module Blender
  module Lock
    include  Blender::Utils::Refinements

    class Flock

      def initialize(name, options)
        @path = options['path'] || File.join('/tmp', name)
        @job_name = name
      end

      def with_lock
        File.open(@path, File::CREAT|File::RDWR, 0644) do |f|
          f.fcntl( Fcntl::F_SETFD, f.fcntl(Fcntl::F_GETFD, 0) | Fcntl::FD_CLOEXEC )
          if f.flock(File::LOCK_NB | File::LOCK_EX) == 0
            begin
              f.write({job: @job_name, pid: Process.pid }.inspect)
              yield if block_given?
            rescue StandardError => e
              raise e
            ensure
              f.flock(File::LOCK_UN)
              f.close
              File.unlink(@path)
            end
          else
            raise LockAcquisitionError, 'Unable to lock using flock'
          end
        end
      end
    end

    def lock(opts = {})
      if Configuration[:lock]['driver']
        lock_klass = Lock.const_get(camelcase(Configuration[:lock]['driver']).to_sym)
        options = Configuration[:lock]['options'].merge(opts)
        lock_klass.new(name, options).with_lock do
          yield if block_given?
        end
      else
        yield if block_given?
      end
    end
  end
end
