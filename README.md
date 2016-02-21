# html_tables

[![Gem Version](https://badge.fury.io/rb/html_tables.svg)](https://badge.fury.io/rb/html_tables)
[![Build Status](https://travis-ci.org/elementar/html_tables.svg?branch=master)](https://travis-ci.org/elementar/html_tables)

This gem was extracted from some projects on my company. Everyone is welcome to use and improve upon.

## Installation

Add this line to your application's Gemfile:

    gem 'html_tables'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install html_tables

## Usage

Slim example:

```ruby
= data_table_for(@products, name: :products_table, html: { class: 'custom_table' }) do |t|
  - t.group_by(:category) do |cat|
    em= cat.name
  - t.column(:code, align: :center, width: '9em')
  - t.column(:description) { |p| p.descriptions.first }
  - t.column(:pricing, footer: :sum) do |item, total_in_footer|
    - if item
      = number_to_currency(item.pricing)
    - else
      blink = number_to_currency(total_in_footer)
  - t.column(:quantity, width: '9em') do |p|
    - if p.quantity == 0
      span title='Out of stock' *
    - else
      = number_with_delimiter p.quantity
  - t.column(:status, align: :center, width: '3em', header: { text: 'St.', class: 'status-header' })
  - t.nodata 'No product found.'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
