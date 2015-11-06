module Formalizer

  class Utils

    # SEARCH_PATHS constant
    # Usually formalizer.yml is in root config directory
    # Gem's testing directory is test/dummy/config

    SEARCH_PATHS = %w(config test/dummy/config)


    def self.find_file file_path
      if file_path[0] == '/'
        # probably absolute path
        # raise exception if file not found
        raise FileNotFound, 'file not exists' unless File.exists?file_path
        return File.read(file_path)
      else
        # probably relative path, searching in SEARCH_PATHS
        SEARCH_PATHS.each do |path|
          absolute_file_path = "#{File.expand_path(path)}/#{file_path}"
          return File.read(absolute_file_path) if File.exists?(absolute_file_path)
        end
      end

      # not found anywhere
      raise FileNotFound, 'file not exists' unless File.exists?file_path
    end

  end

end