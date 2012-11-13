# -*- coding: utf-8 -*-

module HtmlTables
  class Railtie < Rails::Railtie
    initializer "html_tables.view_helpers" do
      ActionView::Base.send :include, DataTableHelper
    end
  end
end
