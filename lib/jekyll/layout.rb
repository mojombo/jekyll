module Jekyll
  class Layout
    # Gets the Site object.
    attr_reader :site

    # Gets the name of this layout.
    attr_reader :name

    # Gets/Sets the extension of this layout.
    attr_accessor :extname

    # Gets/Sets the Hash that holds the metadata for this layout.
    attr_accessor :data

    # Gets/Sets the content of this layout.
    attr_accessor :content

    # Initialize a new Layout.
    #
    # site - The Site.
    # base - The String path to the source.
    # name - The String filename of the post file.
    def initialize(site, base, name)
      @site = site
      @base = base
      @name = name

      self.data = {}

      process(name)
    end

    # Extract information from the layout filename.
    #
    # name - The String filename of the layout file.
    #
    # Returns nothing.
    def process(name)
      self.extname =  File.extname(name)
    end

    def defaults_key
      :layout
    end

    def full_path
      File.join(*[@base, @name].map(&:to_s).reject(&:empty?))
    end
  end
end
