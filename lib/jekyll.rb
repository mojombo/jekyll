$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

# Require all of the Ruby files in the given directory.
#
# path - The String relative path from here to the directory.
#
# Returns nothing.
def require_all(path)
  glob = File.join(File.dirname(__FILE__), path, '*.rb')
  Dir[glob].each do |f|
    require f
  end
end

# rubygems
require 'rubygems'

# stdlib
require 'fileutils'
require 'time'
require 'safe_yaml/load'
require 'English'
require 'pathname'
require 'logger'

# 3rd party
require 'liquid'
require 'kramdown'
require 'colorator'
require 'toml'

# internal requires
require 'jekyll/version'
require 'jekyll/utils'
require 'jekyll/log_adapter'
require 'jekyll/stevenson'
require 'jekyll/deprecator'
require 'jekyll/configuration'
require 'jekyll/document'
require 'jekyll/collection'
require 'jekyll/plugin_manager'
require 'jekyll/frontmatter_defaults'
require 'jekyll/site'
require 'jekyll/convertible'
require 'jekyll/url'
require 'jekyll/layout'
require 'jekyll/page'
require 'jekyll/post'
require 'jekyll/excerpt'
require 'jekyll/draft'
require 'jekyll/filters'
require 'jekyll/static_file'
require 'jekyll/errors'
require 'jekyll/related_posts'
require 'jekyll/cleaner'
require 'jekyll/entry_filter'
require 'jekyll/layout_reader'
require 'jekyll/publisher'
require 'jekyll/renderer'

# extensions
require 'jekyll/plugin'
require 'jekyll/converter'
require 'jekyll/generator'
require 'jekyll/command'
require 'jekyll/liquid_extensions'

require_all 'jekyll/commands'
require_all 'jekyll/converters'
require_all 'jekyll/converters/markdown'
require_all 'jekyll/generators'
require_all 'jekyll/tags'

# plugins
require 'jekyll-filesystem-adapter'
require 'jekyll-coffeescript'
require 'jekyll-sass-converter'
require 'jekyll-paginate'
require 'jekyll-gist'

SafeYAML::OPTIONS[:suppress_warnings] = true

module Jekyll

  # Public: Tells you which Jekyll environment you are building in so you can skip tasks
  # if you need to.  This is useful when doing expensive compression tasks on css and
  # images and allows you to skip that when working in development.

  def self.env
    ENV["JEKYLL_ENV"] || "development"
  end

  # Public: Generate a Jekyll configuration Hash by merging the default
  # options with anything in _config.yml, and adding the given options on top.
  #
  # override - A Hash of config directives that override any options in both
  #            the defaults and the config file. See Jekyll::Configuration::DEFAULTS for a
  #            list of option names and their defaults.
  #
  # Returns the final configuration Hash.
  def self.configuration(override)
    config = Configuration[Configuration::DEFAULTS]
    override = Configuration[override].stringify_keys
    config = config.read_config_files(config.config_files(override))

    # Merge DEFAULTS < _config.yml < override
    config = Utils.deep_merge_hashes(config, override).stringify_keys
    set_timezone(config['timezone']) if config['timezone']

    config
  end

  # Static: Set the TZ environment variable to use the timezone specified
  #
  # timezone - the IANA Time Zone
  #
  # Returns nothing
  def self.set_timezone(timezone)
    ENV['TZ'] = timezone
  end

  def self.logger
    @logger ||= LogAdapter.new(Stevenson.new)
  end

  def self.logger=(writer)
    @logger = LogAdapter.new(writer)
  end

  # For backwards-compatibility.
  # Remove in v3.0.
  def self.sanitized_path(base_directory, questionable_path)
    Jekyll::FileSystemAdapter.sanitized_path(base_directory, questionable_path)
  end
end
