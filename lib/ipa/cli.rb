require 'thor'
require "pathname"

module Ipa
  class CLI < Thor
    def initialize(*args)
      super
      @path = File.join(ENV['HOME'], ['Music','iTunes Media', 'Mobile Applications'])
    end
    desc "list", "list your downloaded app names"
    def list(path = @path)
      puts @path
      Dir.entries(path) do |ipa|
        puts ipa
      end
    end

    desc "clean", "remove clean cache dir[.ipa]"
    def clean
      puts Dir.pwd
    end
  end
end
