require 'spec_helper'
require 'ostruct'

class FakeBuilder < ActionView::Base
  include HtmlTables::DataTableHelper
end

RSpec.describe HtmlTables::DataTable do
  let(:col0) { [] }
  let(:col1) { [{ id: 1, name: 'Record One' }, { id: 2, name: 'Record Two' }].map &OpenStruct.method(:new) }
  let(:builder) { FakeBuilder.new }

  describe 'basic usage' do
    it 'should render nicely when empty' do
      html = builder.data_table_for col0 do |t|
        t.column :id
        t.column :name
        t.nodata 'No records found'
      end

      expect(html).to have_tag :tbody do
        with_tag :tr, count: 1 do
          with_tag :td, text: 'No records found', with: { colspan: 2 }
        end
      end
    end

    it 'should render nicely with records and explicit columns' do
      html = builder.data_table_for col1 do |t|
        t.column :id
        t.column :name
        t.nodata 'No records found'
      end

      expect(html).not_to have_tag :td, text: 'No records found'
      expect(html).to have_tag :tbody do
        with_tag :tr do
          with_tag :td, text: '1'
          with_tag :td, text: 'Record One'
        end
        with_tag :tr do
          with_tag :td, text: '2'
          with_tag :td, text: 'Record Two'
        end
      end
    end
  end

  describe 'totals' do
    it 'should calculate totals correctly'
  end

  describe 'grouping' do
    it 'should group records correctly'
  end

  describe 'column definition' do
    it 'should auto-detect columns from ActiveModel compatible models'
    it 'should allow custom columns'
  end

  describe 'alignment' do
    it 'should apply the correct classes when aligning columns'
  end

  describe 'headers' do
    it 'should allow overriding the header text'
    it 'should allow overriding the header style'
  end
end