require 'singleton'

module HtmlTables
  def self.setup
    yield Configuration.instance
  end

  class Configuration
    include Singleton

    attr_accessor :use_entity_shortcuts, :url_generator_proc, :default_table_classes

    def initialize
      @use_entity_shortcuts = ::Rails.env.development?
      @url_generator_proc = -> obj { url_for(obj) }
      @default_table_classes = %w(table table-striped table-bordered)
    end
  end
end