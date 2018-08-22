# encoding: utf-8

# Copyright (c) [2018] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "forwardable"
require "opensuse_mirror/update"

module OpensuseMirror
  class Updates
    UPDATES_ROOT = "rsync.opensuse.org::opensuse-updates/"
    attr_reader :list

    extend Forwardable
    def_delegators :@list, :size, :map

    def initialize(list=[])
      @list = list
    end

    def find(directory)
      @list.find { |u| u.directory == directory }
    end

    def self.available
      result = `rsync --list-only '#{UPDATES_ROOT}'`
      raise "Cannot rsync to server #{UPDATES_ROOT}" if $?.exitstatus != 0

      grepped_result = result.lines.grep /^d.* \d+\.\d+\S*$/
      directories = grepped_result.map { |l| l.sub(/^.* (\d+\.\d+\S*$)/,
      '\\1').strip }
      list = directories.map { |d| Update.new d }

      return Updates.new list
    end
  end
end
