require 'spec_helper'
require 'ostruct'

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.string :sex
    t.string :role
  end
end

class User < ActiveRecord::Base
  extend Enumerize
  include Symbolize::ActiveRecord

  enumerize :sex, :in => [:male, :female]
  symbolize :role, :in => [:manager, :admin]
end

class FakeBuilder < ActionView::Base
  include HtmlTables::DataTableHelper
end

RSpec.describe HtmlTables::DataTable do

  before do
    I18n.config.enforce_available_locales = false
    I18n.available_locales = ["pt"]
    I18n.default_locale = :"pt"
    I18n.backend.store_translations(:pt, :enumerize => { :user => { :sex => {
        :female => 'Feminino', :male => 'Masculino'
    } } },
     :activerecord => { :symbolizes => { :user => { :role => { :manager => 'Gerente', :admin => 'Administrador' } } } })
    User.create(sex: :female, role: :manager)
  end

  let(:col0) { [] }
  let(:col1) { [{ id: 1, name: 'Record One', enabled: true },
                { id: 2, name: 'Record Two', enabled: false }].map &OpenStruct.method(:new) }
  let(:builder) { FakeBuilder.new }
  let(:user_collection) { User.all }

  describe 'basic usage' do
    it 'should render nicely when empty' do
      html = builder.data_table_for col0 do |t|
        t.column :id
        t.column :name
        t.nodata 'No records found'
      end

      expect(html).to have_tag :tbody do
        with_tag :tr, count: 1
        with_tag :td, count: 1, text: 'No records found', with: { colspan: 2 }
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
        with_tag :tr, text: 'Record One'
        with_tag :tr, text: 'Record Two'
      end
    end

    it 'should translate values from enumerize' do
      html = builder.data_table_for user_collection do |t|
        t.column :sex
        t.nodata 'No records found'
      end

      expect(html).to have_tag :tbody do
        with_tag :td, text: 'Feminino'
      end
    end

    it 'should translate values from symbolize' do
      html = builder.data_table_for user_collection do |t|
        t.column :role
        t.nodata 'No records found'
      end

      expect(html).to have_tag :tbody do
        with_tag :td, text: 'Gerente'
      end
    end
  end

  describe 'row class' do
    it 'should add the row class on the correct rows' do
      html = builder.data_table_for col1 do |t|
        t.row_class :disabled, if: -> rec { !rec.enabled }
        t.column :id
        t.column :name
      end

      expect(html).to have_tag :tbody do
        with_tag :tr, without: { class: 'disabled' }, text: 'Record One'
        with_tag :tr, with: { class: 'disabled' }, text: 'Record Two'
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
