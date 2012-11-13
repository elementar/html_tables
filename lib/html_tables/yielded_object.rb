# -*- coding: utf-8 -*-

module HtmlTables
  class YieldedObject
    attr_reader :t

    def initialize(data_table)
      @t = data_table
    end

    # Adds a checkbox column to the DataTable.
    # If a block is supplied, it is used to determine the initial state of the checkbox.
    def checkbox(id = nil, options = { }, &block)
      options[:block] = block if block_given?
      t.columns[id] = options.reverse_merge! checkbox: true, align: :center
    end

    # Adds a radio button column to the DataTable.
    def radio(id = nil, options = { })
      t.columns[id] = options.reverse_merge! radio: true, align: :center
    end

    # Adds a regular column to the DataTable.
    def column(id, options = { }, &block)
      options[:block] = block if block_given?
      t.columns[id] = options
      nil
    end

    # Sets the 'no-data' message. If not set, no message will be displayed when there's no records to show.
    def nodata(msg)
      t.nodata_message = msg
      nil
    end

    def item_url(&block)
      t.item_url_block = block
      nil
    end

    def row_class(cls, options = { })
      t.row_classes << [cls, options]
    end
  end
end
