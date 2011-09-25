require "readline"

module Spork
  class TabCompletion
    def self.init
      Readline.completion_append_character = nil
      Readline.completion_proc = proc {|s| Dir[s + "*"].map {|m| File.directory?(m) ? m + "/" : m}}
    end
  end
end
