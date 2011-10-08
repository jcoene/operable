# Operable

An easy way to perform simple operations (addition, subtraction, multiplication, division) on your models. It is tested with ActiveRecord and Mongoid and should work with any ActiveModel compliant class.

[![travis](https://secure.travis-ci.org/jcoene/operable.png)](http://travis-ci.org/jcoene/operable)

## A Simple Example

Let's say we're collecting records of Baseball games. A `Team` model has various stats like `W`, `L`, `T`, etc. Including Operable in your model definition lets you use the `+`, `-`, `*` and `/` operators on objects just as you would on primatives, returning a new instance of the model class containing the result of your desired operation.

```ruby
# Create team instances for the 2 NY baseball teams:
yankees = Team.new :w => 5, :l => 4, :t => 1
mets =    Team.new :w => 3, :l => 7, :t => 0

# Get their combined totals
yankees + mets # => #<Team w: 8, l: 11, t: 1>

# How much better are the yankees?
yankees - mets # => #<Team w: 2, l: -3, t: 1>

# If the yankees keep this up for the rest of the season...
yankees * 16.2 # => #<Team w: 81, l: 65, t: 16>
```

## Getting Started

First, add operable to your Gemfile:

```ruby
gem 'operable'
```

Next, include the module in your model and specify which fields to operate on:

```ruby
# ActiveRecord:
class Team < ActiveRecord::Base
  include Operable
  operable_on :w, :l, :t
end

# Mongoid:
class Team
  include Mongoid::Document
  include Operable
  field :w
  field :l
  field :t
  operable_on :w, :l, :t
end
```

That's it! You can call operable_on multiple times to add more fields.

## Operations

Four operations are provided: `+`, `-`, `*`, `/`.

```ruby
red = Color.new   :r => 128, :g => 0,   :b => 0
green = Color.new :r => 0,   :g => 128, :b => 0
blue = Color.new  :r => 0,   :g => 0,   :b => 128

yellow = green + red # => #<Color r: 128, g: 128, b: 0>
grey = yellow + blue # => #<Color r: 128, g: 128, b: 128>
bright_red = red * 2 # => #<Color r: 255, g: 0,   b: 0>
dark_grey = grey / 3 # => #<Color r: 43,  g: 43,  b: 43>
```

## Equality

Compare the equality of operable objects with the `matches?` method:

```ruby
purple = Color.new :r => 128, :g => 0, :b => 128

purple.matches?(red + blue)  #=> true
purple.matches?(red + green) #=> false
```

### Operate On All (Mongoid only)

Mongoid models define their fields explicitly in the model declaration. We can use this to automatically determine what to operate on:

```ruby
class Team
  include Mongoid::Document
  include Operable
  field :w
  field :l
  field :t
  operable_on_all # operates on w, l and t.
  operable_on_all_except :t # operates on w and l
end
```

### Operate On Associations (Mongoid only)

We can include associations in our list of operable fields just as with normal attributes!

First, include Operable on **both** documents. Then, on the **parent** document, manually specify the name of the association to *operable_on* (associations are not included by *operable_on_all* methods)

```ruby
class First
  include Mongoid::Document
  include Operable
  field :a
  field :b
  embeds_one :second
  operable_on_all
  operable_on :second
end

class Second
  include Mongoid::Document
  include Operable
  field :c
  field :d
  embedded_in :first
  operable_on_all
end

f1 = First.new :a => 1, :b => 2, :second => Second.new(:c => 1, :d => 2)
f2 = First.new :a => 2, :b => 3, :second => Second.new(:c => 2, :d => 3)
f3 = f1 + f2  # => #<First a: 3, b: 5>
f3.second     # => #<Second c: 3, d: 5>
```

## Enhancements and Pull Requests

If you find the project useful but it doesn't meet all of your needs, feel free to fork it and send a pull request. I'd especially love contributions that enhance behavior with ActiveRecord. Please make sure to include specs!

## License

MIT license, go wild.
