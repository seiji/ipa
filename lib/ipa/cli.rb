# -*- coding: utf-8 -*-
require 'thor'
require "pathname"
require 'shellwords'

DIR_CACHE = '.cache'

module Ipa
  class CLI < Thor
    def initialize(*args)
      super
      @path = File.join(ENV['HOME'], %w(Music iTunes iTunes\ Media Mobile\ Applications))
      @cache_dir  = Pathname.new(File.join(Dir.pwd, DIR_CACHE))
      @index_path = Pathname.new(File.join(@cache_dir, 'index.yml'))
    end

    desc "list", "list app names you downloaded via iTunes"
    def list(itunes_path = @path)
      @cache_dir.mkdir unless @cache_dir.exist?
      files = {}
      Dir.glob("#{itunes_path}/*.ipa") do |file_path|
        file = Pathname.new(file_path)
        name, version = Util::split_name(file.basename.to_s)
        if name and version
          dst = File.join(@cache_dir, "#{name} #{version}.ipa")
          unless (File.exists?(dst))
            FileUtils.cp(file_path, dst)
          end

          ipa = Ipa::Obj.new(dst)
          info = ipa.info
          identifier = info['CFBundleIdentifier']
          puts "%-20s: %s"  % [info['CFBundleName'], identifier]
          files[identifier] = dst
        end
      end
      File.open(@index_path, "w") do |file|
        file.write files.to_yaml
      end
    end

    desc "app [identifier]", "list files in *.app"
    def app(identifier, regex = nil)
      index = YAML::load_file @index_path
      file_path = index[identifier]
      if file_path
        ipa = Ipa::Obj.new(file_path)
        ipa.contents do |f, rel_path|
          basename = File.basename(f)
          puts rel_path
        end
      end
    end

    desc "clean", "remove clean cache dir [#{DIR_CACHE}]"
    def clean
      if File.exists?(@cache_dir)
        FileUtils.rm_r(@cache_dir)
      end
    end

    desc "create", "create ipa from .app"
    def create(path_app)
      # make Payload
    end

    private

  end
end
