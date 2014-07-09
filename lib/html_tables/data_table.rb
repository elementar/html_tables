# -*- coding: utf-8 -*-

module HtmlTables
  class DataTable
    attr_reader :collection, :options, :row_classes
    attr_accessor :nodata_message, :item_url_options

    def initialize(builder, collection, options = {})
      @builder = builder
      @collection = collection
      @options = options
      @item_url_options = {}
      @row_classes = []
    end

    def auto_generate_columns!
      model.accessible_attributes.each do |attr|
        col = model_columns[attr]
        object_to_yield.column col.name unless col.nil?
      end
    end

    def model
      @model ||= begin
        n = collection.model_name.constantize if collection.respond_to?(:model_name)
        n = n.name if n.is_a?(ActiveModel::Name)
        n
      end
      @model ||= collection.first.try(:class)
      @model ||= options[:name].to_s.singularize.constantize
    end

    def model_name
      @model_name ||= collection.model_name if collection.respond_to?(:model_name)
      @model_name ||= model.model_name
    end

    def model_columns
      @model_columns ||= ActiveSupport::HashWithIndifferentAccess[*model.columns.map { |c| [c.name, c] }.flatten]
    end

    def object_to_yield
      @ctl ||= YieldedObject.new(self)
    end

    def columns
      @columns ||= ActiveSupport::OrderedHash.new
    end

    def header_for(column_id)
      return nil if column_id.nil?
      return @builder.content_tag(:i, nil, class: 'icon-check') if columns[column_id][:checkbox]
      v ||= I18n.t(column_id, scope: [:tables, options[:name] || :default], raise: true) rescue nil
      v ||= I18n.t(column_id, scope: [:tables, :default], raise: true) rescue nil
      v ||= I18n.t(column_id, scope: [:activerecord, :attributes, model_name.i18n_key], raise: true) rescue nil
      v ||= I18n.t(column_id, scope: [:mongoid, :attributes, model_name.i18n_key], raise: true) rescue nil
      v ||= I18n.t(column_id, scope: [:attributes], raise: true) rescue nil
      v ||= model_columns[column_id].human_name rescue nil

      v || column_id.to_s.humanize
    end

    def url_for(item)
      return nil unless item_url_options.fetch(:enabled, true)
      return item_url_options[:block].call(item) if item_url_options[:block]
      @builder.url_for(item) rescue nil
    end

    def row_options_for(item)
      h = {}

      url = self.url_for(item)
      h[:data] = { url: url } if url

      classes = []
      self.row_classes.each do |cls, opts|
        next if opts[:if] && !test(item, &opts[:if])
        next if opts[:unless] && test(item, &opts[:unless])
        classes << cls
      end

      h[:class] = classes.uniq * ' ' unless classes.empty?

      h
    end

    def group_by(column_or_lambda, &block)
      options[:group] = { block: block, proc: case column_or_lambda
        when String, Symbol
          ->(obj) { obj.public_send(column_or_lambda) }
        when Proc
          column_or_lambda
        else
          raise ArgumentError.new "group_by first argument must be a String, Symbol or Proc"
      end }
      self
    end

    def test(item)
      yield item
    end
  end
end
