# html_tables

This gem was extracted from some projects on my company. Everyone is welcome to use and improve upon.

## Installation

Add this line to your application's Gemfile:

    gem 'html_tables'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install html_tables

## Usage

HAML example:

    = data_table_for(@products, name: :products_table, html: { class: 'custom_table' }) do |t|
      - t.group_by(:category) do |cat|
        %em= cat.name
      - t.column(:code, align: :center, width: '9em')
      - t.column(:description) { |p| p.descriptions.first }
      - t.column(:pricing)
      - t.footer(:pricing, reduce: :+) do |total|
        = number_to_currency(total)
      - t.column(:quantity, width: '9em') do |p|
        - if p.quantity == 0
          %span.label.label-important.stack-right(title = 'Out of stock')
            %i.icon-flag.icon-white
        - else
          .c= number_with_delimiter p.quantity
      - t.column(:situation, align: :center, width: '9em')
      - t.nodata 'No product found.'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
