class Formalizer

  class Utils

    # SEARCH_PATHS constant
    # Usually formalizer.yml is in root config directory
    # Gem's testing directory is test/dummy/config

    SEARCH_PATHS = %w(config test/dummy/config test/dummy)


    def self.find_file file_path, read = true, search_paths = SEARCH_PATHS

      if file_path[0] == '/'
        # probably absolute path
        # raise exception if file not found
        raise FileNotFound, 'file not exists' unless File.exists?file_path
        return read ? File.read(file_path) : fild_path
      else
        # probably relative path, searching in SEARCH_PATHS
        search_paths.each do |path|
          absolute_file_path = "#{File.expand_path(path)}/#{file_path}"
          begin
            return (read ? File.read(absolute_file_path) : absolute_file_path) if File.exists?(absolute_file_path)
          rescue Errno::EISDIR
            raise FileNotFound, 'path is a directory, not a file'
          end
        end
      end

      # not found anywhere
      raise FileNotFound, 'file not exists' unless File.exists?file_path
    end


    # tries getting the full local path to a relative/absolute path
    # (image src attribute, stylesheet rel attribute)
    # * +path+ - the original relative/absolute path

    def self.final_path path
      if path.start_with?'http'
        # external path, nothing to do, return path as is
        return path
      elsif path[0..6].include?'assets'
        # path is probably an asset, searching in assets
        final_path = self.find_file(Pathname.new(path).basename.to_s, false, Rails.application.config.assets.paths)
      else
        # path is a relative path
        begin
          final_path = self.find_file(path, false)
        rescue Formalizer::FileNotFound
          # path not found
          return ''
        end
      end
      return "file:///#{final_path}"
    end

  end

end