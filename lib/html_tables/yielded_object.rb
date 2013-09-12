# -*- coding: utf-8 -*-

module HtmlTables
  class YieldedObject
    attr_reader :t

    def initialize(data_table)
      @t = data_table
    end

    # Adds a checkbox column to the DataTable.
    # If a block is supplied, it is used to determine the initial state of the checkbox.
    # @param [Hash] options the checkbox options
    # @option options [TrueClass,FalseClass] checked the initial state of the checkbox.
    # @option options [Proc] block a block which will be evaluated to define the initial state of the checkbox.
    # @option options [String] value_method the method to be called to define the checkbox value. Default = :id
    def checkbox(id = nil, options = { }, &block)
      options[:block] = block if block_given?
      t.columns[id] = options.reverse_merge! checkbox: true, align: :center
    end

    # Adds a radio button column to the DataTable.
    # @param [Hash] options the radio options
    # @option options [String] value_method the method to be called to define the radio value. Default = :id
    def radio(id = nil, options = { })
      t.columns[id] = options.reverse_merge! radio: true, align: :center
    end

    # Adds a regular column to the DataTable.
    def column(id, options = { }, &block)
      options[:block] = block if block_given?
      t.columns[id] = options
      nil
    end

    def group_by(column_or_lambda, &block)
      t.group_by column_or_lambda, &block
      self
    end

    def footer(id, options = {}, &block)
      f = {}
      f[:map] = options.delete(:map) || id.to_sym.to_proc
      f[:reduce] = options.delete(:reduce) || :+
      f[:format] = block_given? ? block : :to_s.to_proc
      t.columns[id][:footer] = f
    end

    # Sets the 'no-data' message. If not set, no message will be displayed when there's no records to show.
    def nodata(msg)
      t.nodata_message = msg
      nil
    end

    def item_url(enabled = true, &block)
      t.item_url_options = { :block => block, :enabled => enabled }
      nil
    end

    def row_class(cls, options = { })
      t.row_classes << [cls, options]
    end
  end
end
