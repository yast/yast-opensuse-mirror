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
