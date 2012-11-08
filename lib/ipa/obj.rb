require "zipruby"
require 'shellwords'
require "plist"

module Ipa
  class Obj
    attr_reader :path
    attr_reader :name
    attr_reader :version
    
    def initialize(path)
      @path = path
      file = Pathname.new(path)
      @dirname = file.dirname.to_s
      @name, @version = Util::split_name(file.basename.to_s)
      unless @name or @version
        raise RuntimeError
      end
      extract
    end

    def dirname
      File.join(@dirname, "#{@name} #{@version}")
    end

    def apppath
      payload_path = File.join(dirname, 'Payload')
      Dir.glob("#{payload_path}/*.app") do |f|
        return f
      end
      nil
    end

    def contents                # inside .app
      Dir.glob("#{apppath}/**/*.*") do |f|
        rel_path = f.sub(/#{apppath}\//, '')
        yield(f, rel_path)
      end
    end

    def infopath
      File.join(apppath, 'Info.plist')
    end

    def info
      `plutil -convert xml1 #{infopath.shellescape}`
      Plist::parse_xml(infopath)
    end

    def extract
      out_dir = dirname
      return if (File.exists?(out_dir))
      Zip::Archive.open(@path) do |archives|
        archives.each do |a|
          dirname = File.dirname(a.name).force_encoding('UTF-8')
          FileUtils.makedirs(File.join(out_dir, dirname))
          unless a.directory?
            File.open(File.join(out_dir,a.name.force_encoding('UTF-8')), "w+b") do |f|
              f.print(a.read)
            end
          end
        end
      end
    end
  end
end
