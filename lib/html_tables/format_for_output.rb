# -*- coding: utf-8 -*-

module HtmlTables
  module FormatForOutput
    def format_for_output
      case self
        when Date, Time, DateTime
          I18n.l(self, format: :short)
        when ActiveRecord::Base
          self.to_label(:short)
        when TrueClass, FalseClass
          I18n.t(self.to_s)
        else
          self
      end
    end
  end
end

Object.send(:include, HtmlTables::FormatForOutput)
