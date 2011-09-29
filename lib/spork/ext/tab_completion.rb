require "readline"

module Spork
  module Ext
    class TabCompletion
      def self.init
        Readline.completion_append_character = nil
        Readline.completion_proc = lambda do |s|
          Dir[s + "*"].map do |m|
            File.directory?(m) && m !~ /\/$/ ? m + "/" : m
          end
        end
      end
    end
  end
end
