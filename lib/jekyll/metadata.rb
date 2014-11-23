module Jekyll
  class Metadata
    attr_reader :site, :metadata, :cache

    def initialize(site)
      @site = site

      # Configuration options
      @full_rebuild = site.config['full_rebuild']
      @disabled = site.config['no_metadata']

      # Read metadata from file
      read_metadata

      # Initialize cache to an empty hash
      @cache = {}
    end

    # Add a path to the metadata
    #
    # Returns true, also on failure.
    def add(path)
      return true if not File.exist? path

      metadata[path] = {
        "mtime" => File.mtime(path),
        "deps" => []
      }
      cache[path] = true
    end

    # Force a path to regenerate
    #
    # Returns true.
    def force(path)
      cache[path] = true
    end

    # Clear the metadata and cache
    #
    # Returns nothing
    def clear
      metadata = {}
      cache = {}
    end

    # Checks if a path should be regenerated
    #
    # Returns a boolean.
    def regenerate?(path, add = true)
      return true if @disabled

      # Check for path in cache
      if cache.has_key? path
        return cache[path]
      end

      # Check path that exists in metadata
      if data = metadata[path]
        data["deps"].each do |dependency|
          if regenerate?(dependency)
            return cache[dependency] = cache[path] = true
          end
        end
        if data["mtime"].eql? File.mtime(path)
          return cache[path] = false
        else
          return !add || add(path)
        end
      end

      # Path does not exist in metadata, add it
      return !add || add(path)
    end

    # Add a dependency of a path
    #
    # Returns nothing.
    def add_dependency(path, dependency)
      return if (metadata[path].nil? || @disabled)

      metadata[path]["deps"] << dependency unless metadata[path]["deps"].include? dependency
      regenerate? dependency
    end

    # Write the metadata to disk
    #
    # Returns nothing.
    def write
      File.open(metadata_file, 'w') do |f|
        f.write(metadata.to_yaml)
      end
    end

    # Produce the absolute path of the metadata file
    #
    # Returns the String path of the file.
    def metadata_file
      site.in_source_dir('.jekyll-metadata')
    end

    private

    # Read metadata from the metadata file, if no file is found,
    # initialize with an empty hash
    #
    # Returns the read metadata.
    def read_metadata
      @metadata = if !(@full_rebuild || @disabled) && File.file?(metadata_file)
        SafeYAML.load(File.read(metadata_file))
      else
        {}
      end
    end
  end
end
