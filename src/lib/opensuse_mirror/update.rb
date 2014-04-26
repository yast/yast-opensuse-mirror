module OpensuseMirror
  class Update < Struct.new(:directory, :mirrored)
    def initialize (directory, mirrored = false)
      super directory, mirrored
    end
  end
end
