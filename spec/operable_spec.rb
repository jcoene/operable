require "spec_helper"

class First
  include Mongoid::Document
  include Operable

  field :a, :type => Integer
  field :b, :type => Integer

  embeds_one :second

  operable_on_all
  operable_on :second

end

class Second
  include Mongoid::Document
  include Operable

  field :c, :type => Integer
  field :d, :type => Integer

  embedded_in :first

  operable_on_all
end

class Business
  include Mongoid::Document
  include Operable

  field :employees, :type => Integer
  field :revenue, :type => Float
  field :taxes, :type => Float
  operable_on :employees, :revenue
end

class OtherBusiness
  include Mongoid::Document
  include Operable

  field :employees, :type => Integer
  field :revenue, :type => Float
  field :taxes, :type => Float
  operable_on :employees
  operable_on :taxes
end

class SecondBusiness
  include Mongoid::Document
  include Operable

  field :employees, :type => Integer
  field :revenue, :type => Float
  field :taxes, :type => Float

  operable_on_all
end

class ThirdBusiness
  include Mongoid::Document
  include Operable

  field :employees, :type => Integer
  field :revenue, :type => Float
  field :taxes, :type => Float
  operable_on_all_except :revenue, :taxes
end

class Account
  include Mongoid::Document
  include Operable

  field :dollars, :type => Integer
end

class Item
  include Mongoid::Document
  include Operable

  field :inventory, :type => Integer
  field :price, :type => Float
  operable_on :inventory
end

class City < ActiveRecord::Base
  include Operable
  has_one :dump
  operable_on :population, :revenue, :dump
end

class Dump < ActiveRecord::Base
  include Operable
  belongs_to :city
  operable_on :employees, :weight
end

class Town < ActiveRecord::Base
  include Operable
  operable_on_all
end

describe Operable do

  describe 'fields' do

    it 'are required for an operation' do
      a1 = Account.new :dollars => 5
      a2 = Account.new :dollars => 10
      lambda { a1+a2 }.should raise_error(RuntimeError, "Please specify one or more fields via operable_on in your model definition!")
      lambda { a1-a2 }.should raise_error(RuntimeError, "Please specify one or more fields via operable_on in your model definition!")
      lambda { a1*2 }.should raise_error(RuntimeError, "Please specify one or more fields via operable_on in your model definition!")
    end

    it 'are specified by operable_on' do
      Business.operable_fields.should eql %w[employees revenue]
    end

    it 'can be specified by operable_on multiple times' do
      OtherBusiness.operable_fields.should eql %w[employees taxes]
    end

    it 'can all be included' do
      SecondBusiness.operable_fields.sort.should eql %w[employees revenue taxes]
    end

    it 'can all be included with exceptions' do
      ThirdBusiness.operable_fields.sort.should eql %w[employees]
    end

  end

  describe 'equality' do

    before :all do
      @c1 = City.new :population => 15, :revenue => 10_000
      @c2 = City.new :population => 35.00, :revenue => 30_000
      @c3 = City.new :population => 35, :revenue => 30_000.00
    end

    it 'returns true if equal on operable fields' do
      @c2.matches?(@c3).should eql true
    end

    it 'returns false if not equal on operable fields' do
      @c1.matches?(@c3).should eql false
    end

  end

  describe 'operations' do

    before :all do
      @c1 = City.new :population => 15, :revenue => 10_000
      @c2 = City.new :population => 35.00, :revenue => 30_000
      @c3 = City.new :population => 35, :revenue => 30_000.00
      @c4 = City.new
    end

    describe 'addition and subtraction' do

      it 'adds' do
        c = @c1 + @c2
        c.population.should eql(@c1.population + @c2.population)
        c.revenue.should eql(@c1.revenue + @c2.revenue)
      end

      it 'subtracts' do
        c = @c2 - @c1
        c.population.should eql(@c2.population - @c1.population)
        c.revenue.should eql(@c2.revenue - @c1.revenue)
      end

      it 'handles nil values' do
        (@c1 + @c4).population.should eql @c1.population
        (@c1 - @c4).population.should eql @c1.population
        (@c4 + @c2).population.should eql @c2.population
        (@c4 - @c2).population.should eql(-@c2.population)
      end

      it 'handles nil objects' do
        (@c1 + nil).population.should eql @c1.population
        (@c1 - nil).population.should eql @c1.population
      end

      it 'handles nil objects as part of an enumerable' do
        [@c1, @c2, nil, @c3].sum.population.should eql (@c1.population + @c2.population + @c3.population)
      end

      it 'handles zero objects as part of an enumerable' do
        [@c1, @c2, 0, @c3].sum.population.should eql (@c1.population + @c2.population + @c3.population)
      end
    end

    describe 'multiplication and division' do

      it 'multiplies' do
        c = @c1 * 3
        c.population.should eql(@c1.population * 3)
        c.revenue.should eql(@c1.revenue * 3)
      end

      it 'divides' do
        c = @c1 / 2
        c.revenue.should eql(@c1.revenue / 2)
      end

      it 'handles nil values' do
        (@c1 * 0).population.should eql 0
        (@c4 * 0).population.should eql 0
        (@c4 * 2).population.should eql 0
        (@c4 / 4).population.should eql 0
        lambda { @c1 / 0 }.should raise_error
        lambda { @c4 / 0 }.should raise_error
      end

    end

  end

  describe 'compatibility with' do

    describe 'mongoid' do

      before :all do
        @b1 = Business.new :employees => 5, :revenue => 500_000, :taxes => 150_000.11
        @b2 = Business.new :employees => 30, :revenue => 2_000_000, :taxes => 450_000.22
      end

      it 'only operates on specified fields' do
        b = @b1 + @b2
        b.taxes.should be_nil
      end

      it 'retains field type' do
        b = @b1 + @b2
        b.revenue.should eql 2_500_000.00
        b.revenue.should be_a(Float)
      end

      it 'can guess operable fields' do
        SecondBusiness.operable_fields.sort.should eql %w[employees revenue taxes]
      end

      it 'can process singular associations' do
        f1 = First.new :second => Second.new(:c => 1, :d => 2)
        f2 = First.new :second => Second.new(:c => 2, :d => 3)
        f = f1 + f2
        f.second.c.should eql 3
        f.second.d.should eql 5
      end

    end

    describe 'active record' do

      before :all do
        @c1 = City.new :population => 500, :revenue => 500_000, :established => "1983/1/1"
        @c2 = City.new :population => 1_000, :revenue => 1_000_000, :established => "1800/9/5"
      end

      it 'only operates on specified fields' do
        c = @c1 + @c2
        c.population.should eql 1_500
        c.established.should be_nil
      end

      it 'retains field type' do
        c = @c1 + @c2
        c.revenue.should eql 1_500_000.00
        c.revenue.should be_a(Float)
      end

      it 'can guess operable fields' do
        Town.operable_fields.sort.should eql %w[population revenue]
      end

      it 'can process singular associations' do
        c1 = City.new :population => 1, :revenue => 1, :dump => Dump.new(:employees => 1, :weight => 6)
        c2 = City.new :population => 4, :revenue => 4, :dump => Dump.new(:employees => 6, :weight => 14)
        c3 = (c1 + c2)
        c4 = (c1 - c2)
        c3.dump.employees.should eql 7
        c3.dump.weight.should eql 20
        c4.dump.employees.should eql -5
        c4.dump.weight.should eql -8
      end

      it 'ignores nil associations' do
        (@c1 + @c2).dump.should be_nil
      end

    end

  end

end

