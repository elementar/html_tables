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
    delegate :content_tag, :check_box_tag, :capture, to: :@helper

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
            header_opts = opts.fetch(:header, {})
            header_opts = { text: header_opts } unless header_opts.is_a?(Hash)
            header_opts[:text] ||= opts[:header_title] if opts[:header_title]
            (header_opts[:class] ||= '') << ' check' if opts[:checkbox]

            header_text = header_opts.delete(:text) { t.header_for(name) }
            content_tag(:th, header_text, header_opts)
          end.join.html_safe
        end
      end
    end

    def tfoot
      return ''.html_safe unless t.columns.any? { |_, c| c.has_key?(:footer) }

      content_tag(:tfoot) do
        content_tag(:tr) do
          t.columns.map do |id, opts|
            if opts.has_key?(:footer)
              value =
                case opts[:footer]
                when Symbol
                  collection.map(&id.to_proc).public_send(opts[:footer])
                when Proc
                  opts[:footer].call(collection)
                end
              content = opts[:block] ? capture(nil, value, &opts[:block]) : value.to_s
              content_tag(:th, content, extract_td_options(opts, nil))
            else
              content_tag(:th)
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
      v = if opts[:checkbox]
        checked = opts[:checked]
        checked = opts[:block].call(item) if opts[:block]
        check_box_tag "#{column}[]", item.public_send(opts.fetch(:value_method, :id)), checked, extract_check_box_tag_options(opts)
      elsif opts[:radio]
        radio_button_tag "#{column}[]", item.public_send(opts.fetch(:value_method, :id))
      elsif opts[:block]
        args = [item, nil].first(opts[:block].arity)
        capture(*args, &opts[:block])
      else
        tmp = item.public_send(column)
        if tmp.is_a?(Symbol)
          # tries common symbol-storing libraries
          if item.respond_to?(:"#{column}_text") # symbolize
            tmp = item.public_send("#{column}_text")
          elsif item.class.respond_to?(:human_enum_name) # simple_enum
            tmp = item.class.human_enum_name(column, tmp)
          end
        elsif tmp.class.name == 'Enumerize::Value' # enumerize
          tmp = tmp.text
        end
        tmp
      end

      if config.use_entity_shortcuts && v.class.name == 'ActiveRecord::Base'
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

      content_tag(:td, v, extract_td_options(opts, item))
    end

    def extract_check_box_tag_options(opts)
      valid_options = [:disabled]
      opts.select { |k, _| valid_options.include?(k) }
    end

    def extract_td_options(opts, item)
      retval = {}
      retval[:class] = 'c' if opts[:align] == :center

      if opts[:title]
        retval[:title] = if opts[:title].respond_to?(:call)
          opts[:title].call(item).format_for_output
        else
          opts[:title].format_for_output
        end
      end

      retval
    end
  end
end