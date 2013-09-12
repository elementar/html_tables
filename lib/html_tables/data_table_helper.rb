# -*- coding: utf-8 -*-

module HtmlTables
  module DataTableHelper
    def data_table_for(collection, options = {})
      config = HtmlTables::Configuration.instance

      table = DataTable.new(self, collection, options)
      if block_given?
        yield table.object_to_yield
      else
        table.auto_generate_columns!
      end

      Renderer.new(self, table, collection, options).to_html
    end
  end
end
