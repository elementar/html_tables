module HtmlTables
  class Renderer
    def initialize(helper, table, collection, options = {})
      @helper = helper
      @t = table
      @collection = collection
      @options = options
      @config = HtmlTables::Configuration.instance
    end

    def to_html
      cls = config.default_table_classes.dup
      cls << 'table-condensed' if options[:condensed]
      cls << options[:class] if options[:class]
      table_html_options = { class: cls }
      table_html_options.merge!(options[:html]) { |_, v1, v2| [v1, v2].flatten } if options[:html]

      content_tag(:table, table_html_options) do
        content = ''.html_safe
        content << caption << colgroup << thead << tfoot << tbody
      end
    end

    private

    attr_reader :t, :collection, :options, :config
    delegate :content_tag, :capture, to: :@helper

    def caption
      return ''.html_safe unless options.has_key?(:caption)
      content_tag(:caption, options[:caption])
    end

    def colgroup
      content_tag(:colgroup) do
        b = ''.html_safe
        t.columns.each do |_, opts|
          col_opts = { }
          col_opts[:style] = "width: #{opts[:width]}" if opts[:width]
          b << content_tag(:col, col_opts) { }
        end
        b
      end
    end

    def thead
      content_tag(:thead) do
        content_tag(:tr) do
          t.columns.map do |name, opts|
            header_opts = {}
            header_opts[:class] = 'check' if opts[:checkbox]
            header_opts[:header_title] = opts[:header_title] if opts[:header_title]
            content_tag(:th, t.header_for(name), header_opts)
          end.join.html_safe
        end
      end
    end

    def tfoot
      footers = t.columns.map { |_, opts| opts[:footer] }
      return ''.html_safe unless footers.any?

      content_tag(:tfoot) do
        content_tag(:tr) do
          footers.map do |opts|
            if opts.nil?
              content_tag(:th)
            else
              value = collection.map(&opts[:map]).reduce(&opts[:reduce])
              content_tag(:th, capture(value, &opts[:format]))
            end
          end.join.html_safe
        end
      end
    end

    def tbody
      content_tag(:tbody) do
        b = ''.html_safe
        rows = if options[:group]
          collection.group_by {|i| options[:group][:proc].call(i) }.each do |g, l|
            b << content_tag(:tr, class: 'group') do
              content_tag(:th, capture(g, &options[:group][:block]), colspan: t.columns.size)
            end
            render_data_rows(b, l, t)
          end
          collection
        else
          render_data_rows(b, collection, t)
        end
        b << no_data if rows.size.zero?
        b
      end
    end

    def no_data
      return '' if t.nodata_message.nil?
      content_tag(:tr, class: 'nodata') do
        content_tag(:td, colspan: t.columns.size) { t.nodata_message }
      end
    end

    def render_data_rows(b, collection, t)
      collection.each do |item|
        b << content_tag(:tr, t.row_options_for(item)) do
          t.columns.map do |name, opts|
            render_td(item, name, opts)
          end.join.html_safe
        end
      end
    end

    def render_td(item, column, opts)
      td_options = {}

      if opts[:align] == :center
        td_options[:class] = 'c'
      end

      if opts[:title]
        td_options[:title] = if opts[:title].respond_to?(:call)
          opts[:title].call(item)
        else
          opts[:title].to_s
        end
      end

      v = if opts[:checkbox]
        checked = opts[:checked]
        checked = opts[:block].call(item) if opts[:block]
        check_box_tag "#{column}[]", item.public_send(opts.fetch(:value_method, :id)), checked, extract_check_box_tag_options(opts)
      elsif opts[:radio]
        radio_button_tag "#{column}[]", item.public_send(opts.fetch(:value_method, :id))
      elsif opts[:block]
        capture(item, &opts[:block])
      else
        tmp = item.public_send(column)
        tmp = item.public_send("#{column}_text") rescue tmp if tmp.is_a?(Symbol)
        tmp
      end

      if config.use_entity_shortcuts && v.is_a?(ActiveRecord::Base)
        btn = content_tag(:div, class: 'entity-shortcut') do
          link_to(config.url_generator_proc.(v), class: 'btn btn-small') do
            content_tag(:i, nil, class: 'icon-share')
          end
        end rescue nil
      end

      v = if v.is_a?(Enumerable)
        v.inject(''.html_safe) { |b, i| b << ', ' unless b.blank?; b << i.format_for_output }
      else
        v.format_for_output
      end
      v = v.to_s unless v.nil? || v.is_a?(String)

      v = ''.html_safe << btn << v if btn

      content_tag(:td, v, td_options)
    end

    def extract_check_box_tag_options(opts)
      valid_options = [:disabled]
      opts.select { |k, _| valid_options.include?(k) }
    end
  end
end