# Hashoid

Turns your bland json/hashes into flavoursome objects! Useful for consuming web services.

Loosely and shamelessly inspired by Mongoid.

Supports:
* attribute declaration via `field` and `collection` class methods
* field type inference from field name (supports name inflection for collections)
* custom type declaration
* custom transforms
* inheritance

## Installation

Add this line to your application's Gemfile:

    gem 'hashoid'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hashoid

## Usage

```ruby
require 'hashoid'
require 'json'
require 'time'


class Country
  include Hashoid
  field :name
end

class Food
  include Hashoid
  field :sell_by_date, transform: -> s {Time.parse(s)}

  def out_of_date?
    sell_by_date < Time.now
  end
end

class Cheese < Food
  fields [:name, :age] 
  field :origin, type: Country

  def ripe_enough?
    age > 1
  end
end

class CheeseBoard
  include Hashoid
  collection :cheeses
end

cheeseboard_json = '
  { 
    "cheeses" : [
      { 
        "name" : "Camembert",
        "age" : 2,
        "origin" : { "name" : "France" },
        "sell_by_date" : "2014/04/01"
      },
      { 
        "name" : "Gorgonzola",
        "age" : 5,
        "origin" : { "name" : "Italy" },
        "sell_by_date" : "2014/03/28"
      }
    ]
  }'

cheese_board = CheeseBoard.new(JSON.parse(cheeseboard_json))
# or easier
cheese_board = CheeseBoard.from_json(cheeseboard_json)

p cheese_board
p cheese_board.to_h
p cheese_board.to_json
cheese_board.cheeses.each do |cheese|
  if !cheese.out_of_date? && cheese.ripe_enough?
    puts "Have some #{cheese.name} from #{cheese.origin.name}. It's ripe!"
  end
end

```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
