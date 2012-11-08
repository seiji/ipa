module Ipa
  class Util

    def self.split_name(file_name)
      if file_name =~ /^(.+) (.+?)\.ipa$/
        [$1, $2] # [name, version]
      end
    end
  end
end
