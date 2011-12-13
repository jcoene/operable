require "rubygems"
require "bundler/setup"

require "active_record"
require "mongoid"

require "rspec"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.drop_table(table)
end

ActiveRecord::Schema.define(:version => 1) do
  create_table :cities do |t|
    t.column :population, :integer
    t.column :revenue, :float
    t.column :established, :date
  end
  create_table :dumps do |t|
    t.column :city_id, :integer
    t.column :employees, :integer
    t.column :weight, :integer
  end
  create_table :towns do |t|
    t.column :population, :integer
    t.column :revenue, :float
    t.column :established, :date
  end
end

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('mongoid-mapreduce-test')
end

Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)

require File.expand_path("../../lib/operable", __FILE__)
