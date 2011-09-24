require "readline"
require "abbrev"

module Spork
  class TabCompletion
    def self.init
      comp = proc do |s|
        matches = Dir[s + "*"].abbrev.values.uniq
        matches.map {|m| File.directory?(m) ? m + "/" : m}
      end
      Readline.completion_append_character = nil
      Readline.completion_proc = comp
    end
  end
end
