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

require 'timeout'
require 'fcntl'

module Blender
  module Lock
    class Flock
      def initialize(name, options)
        @path = options['path'] || File.join('/tmp', name)
        @timeout = options[:timeout] || 0
        @job_name = name
      end

      def acquire
        @lock_fd = File.open(@path, File::CREAT|File::RDWR, 0644)
        @lock_fd.fcntl( Fcntl::F_SETFD, @lock_fd.fcntl(Fcntl::F_GETFD, 0) | Fcntl::FD_CLOEXEC )
        if @timeout > 0
          Timeout.timeout(@timeout) do
            @lock_fd.flock(File::LOCK_EX)
          end
        else
          locked = @lock_fd.flock(File::LOCK_NB | File::LOCK_EX)
          raise LockAcquisitionError, "Failed to lock file '#{@path}'" if locked == false
        end
        @lock_fd.write({job: @job_name, pid: Process.pid }.inspect)
      end

      def release
        @lock_fd.flock(File::LOCK_UN)
        @lock_fd.close
      end

      def with_lock
        acquire
        yield if block_given?
      rescue Timeout::Error => e
        raise LockAcquisitionError, 'Timeout while waiting for lock acquisition'
      ensure
        release if @lock_fd
      end
    end
  end
end
