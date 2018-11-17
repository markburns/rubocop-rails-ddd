# Rails DDD rubocop Cop

A cop that enforces the following conventions.

# Rails and DDD (Domain Driven Design)

## Summary

This is a convention we can follow that allows us to get much closer to
* Domain driven design
* CQRS - Command Query Responsibility Segregation
* Decoupled applications

By not following the SOLID packaging principles, it is easy to end up with a Rails application
that exhibits the following problems:
* Heavy coupling
* Lack of cohesion
* Brittle

Whilst Rails gives us the conventions to organise our applications around design/technology patterns, it
doesn't typically give us lightweight conventions for organising/splitting apart applications other than
engines.

Engines are a heavy weight solution that still don't give us code organisation conventions beyond
one level of separation.
They suffer from the following issues:

* When separated as separate gems in separate repos:
  * Painful update / release cycle
  * Harder to refactor code between engine and container app quickly
* Still don't enforce not calling internal code
* Complexities can be introduced around having multiple dbs and migrations across multiple apps
* Dependencies need painfully duplicating in host and engine projects

Following a DDD convention gives us the same benefits of code separation conventions from
engines but avoids the negative issues of working with engines.

Engines or service extraction are a natural next step after DDD within an application.

N.B. This code organisation strategy and proposal for supporting DDD in Rails is explicitly not
incompatible with any other design pattern.
In fact it enables easier experimentation with design patterns by allowing you to name and locate
your objects where they make sense.
E.g. if you wish to use the Repository pattern, you just create the file without worrying about
adding a new design pattern folder.
So instead of
```
app/repositories/checkout_repository.rb
app/repositories/order_repository.rb
```

You just create:
```
app/concepts/checkouts/repository.rb
app/concepts/checkouts/orders/repository.rb
```

If later on in development we end up moving to some other design pattern it's a simple file and class rename.

Other side benefits:

* git logs are more usable - they are domain specific for specific folders
`git log master -- app/concepts/checkouts/carts`

* knowing which subset of tests to run is easier - if you changed something order related just run `rspec spec/concepts/checkouts/orders/`
* events have a clear place to be emitted (at the end of a CQRS command - examples follow)



## Why do this?

### Why are we doing this?
An easy to spot and easy to maintain convention allows us to decouple and
disintegrate a complex coupled monolithic application. Also lays groundwork for
an evented architecture.

It is a small amount of overhead compared to vanilla Rails style development.
It allows applications to be maintainable for a longer period.
They don't end up as spaghetti codebases.
Rails can often lead to building spaghetti code when building in a
step-by-step, agile, product-focused fashion.


### What is the expected outcome?

Easier code to maintain and or extract at a later date.


## The 'guide' explanation

General rules:

### Namespacing rules
1. Namespace all new or refactored code
2. Colocate namespaced code on the file system
3. Prefer a pluralised name over singularised - e.g. Products is preferred over Product
4. Always call code in other namespaces via an aggregate root
5. Prefer VerbNoun for command class names
6. Never call code inside another namespace
7. Freely instantiate and call objects etc inside the current namespace
8. Always call aggregate roots by prefixing the namespace with ::

### CQRS - Command Query Responsibility Segregation
Have two types of aggregate root methods
1.  Commands
those that are typically called from POST/PUT/PATCH routes and typically write to files/databases
etc.

2.  Queries
Those that are typically called from GET routes and don't change state by writing to files/databases etc.
Exceptions to this rule might be for e.g. logging, sending data to datadog etc., but never changing actual application state.


### Sub namespace rules
1. Introduce sub-namespaces as soon as there is an obvious related grouping of functionality
2. Sub-namespaces submit to the same rules as top level namespaces.
3. Sub-namespaces are also only accessible via their aggregate roots
4. Don't reach into a sub-namespace without going through the top-level aggregate root

### Testing principles
1. Test extensively within a domain to have enough trust in the code so that you can:
2. Use the clear boundary of aggregate roots to have a simple way to stub/mock
  in tests for objects that collaborate across domains.



## The technical detail


### Namespace all new or refactored code
By keeping all new code inside a namespace we can isolate our code from change

e.g.

```ruby
# good
module Carts
  class AddItem
  end
end

# bad
class AddItemToCart
end

class CartAddItemService
end
```

### Colocate namespaced code on the file system
Following `ActiveSupport::Dependencies` conventions and
keep filenames predictable from the class name and vice-versa.

```ruby
# good
# app/concepts/carts/add_item.rb
module Carts
  class AddItem
  end
end

# bad
# lib/add_item_to_cart.rb
class AddItemToCart
end

# bad
# app/services/cart_add_item_service.rb
class CartAddItemService
end
```


### Prefer a pluralised name over singularised
In general terms pluralised constant names tend to play well with Rails conventions.
Singularised terms like `Cart` are used for `ActiveRecord` classes


### Always call code in other namespaces via an aggregate root

```ruby
# good
# app/concepts/carts.rb
module Carts
  def self.add_item(cart_id, item_id)
    AddItem.call(cart_id, item_id)
  end
end
```

### Prefer VerbNoun for command class names
Where we have a small amount of complexity, perhaps more than a couple of lines of code,
then it may preferable to replace the body of a command aggregate root
with a class.

Commands tend to work well when named as `VerbNoun`.

E.g. `Carts::AddItem`, `Orders::PlaceOrder`, `Payments::ConfirmPayment`


We may want to settle upon a convention of using `.call`, `.perform`, or `.invoke` as a single entry point.

One advantage of `.call` is that command classes are then interchangable with `proc`s, `lambda`s and `method`s.
E.g.

```ruby
def some_method
  puts 'in method'
end

module Carts
  class AddItem
    def self.call(args)
      new.call(args)
    end

    def call(args)
    end
  end
end

module DoThing
  def self.call(args)
  end
end

callable_instance = Carts::AddItem.new(args)
callable_class    = Carts::AddItem
callable_module   = DoThing
callable_proc     = Proc.new { puts 'in proc' }
callable_lambda   = -> { puts 'in lambda' }
callable_method   = method(:some_method)

```

A corollary to this is the equivalent method names should follow the same pattern.

```ruby
module Carts
  def self.add_item!(args)
  end
end
```

And a further corollary is that the event emitted after the command would follow the same
naming but be in the past tense:

There is a [current proposal for events](https://github.com/notonthehighstreet/tea/pull/7) so the specific
format of a message name is not agreed upon at the time of writing.

```
'Carts.item_added'
```

### Never call code inside another namespace

```ruby
# good
# app/concepts/checkouts/confirm_purchase.rb
module Checkouts
  module ConfirmPurchase
    def call
      ::OtherNamespace.some_method(id)
    end
  end
end

# bad
module Checkouts
  module ConfirmPurchase
    def call
      ::OtherNamespace::SomeSubObject.some_method(id)
    end
  end
end
```

Calling code inside another namespace can result in dependency resolution errors
meaning you have to give ActiveSupport::Dependencies hints with `require_dependency`
By calling code at the aggregate root level you can avoid these issues and
it makes it harder to heavily couple to another namespace.

It is desirable and feasible to write a linter to enforce this rule.

### Freely instantiate and call objects inside the current namespace

```ruby
### good
module Checkouts
  module ConfirmPurchase
    def call
      AnotherCheckoutyThing.new.like_this
    end
  end
end

### bad
module Checkouts
  # We don't need an internal object exposing unnecessarily
  def self.another_checkouty_thing_like_this
    ::Checkouts::AnotherCheckoutyThing.new.like_this
  end
end

module Checkouts
  module ConfirmPurchase
    def call
      Checkouts.another_checkouty_thing_like_this
    end
  end
end
```

### Always call aggregate roots by prefixing the namespace with ::

```ruby
module SomeOtherNamespace
  def some_method
    ::Checkouts.confirm_purchase(id)
  end
end
```

This principle also applies to standard library code

```ruby
::File.open("file.txt"){|f| f << "text" }
```

Why?
It makes it clearer when we are calling code external to the current namespace.
It's a visual hint of coupling and easier to grep for


#### CQRS suggestion:

```ruby
# Aggregate roots which are commands are bang style methods
def self.create!(attributes)
end

# Aggregate roots which are queries are not bang style methods
def self.find(id)
end
```

# Commands are an obvious location for emitting events

```ruby
module Thing
  def self.create!(attributes)
    persist(attributes)
    # emit the event after the source of truth has persisted (and correctly respond to queries)
    publish "thing.created", attributes
  end
end

```




### Introduce sub-namespaces as soon as there is an obvious related grouping of functionality

```ruby
module Checkouts
  module Orders
    def self.create(attributes)
      Order.create(attributes)
    end
  end
end
```

A general rule of thumb is that a controller and model with its host of
related helper objects - helpers/services/presenters/decorators/serializers etc would
make a good natural grouping/sub-domain.

### Sub-namespaces submit to the same rules as top level namespaces.
The same concepts also apply in a nested fashion for sub namespaces.

```ruby
#app/concepts/checkouts.rb
module Checkouts
  def self.create_order(attribtues)
    Orders.create(attributes)
  end
end

#app/concepts/checkouts/orders.rb
module Checkouts
  module Orders
    def self.create(attributes)
      Order.create(attributes)
    end
  end
end
```


### Don't reach into a sub-namespace without going through the top-level aggregate root

```ruby
# good
module Checkouts
  module Carts
    class Cart
      def add_to_order
        Orders.add(self)
      end
    end
  end
end

# bad
module Checkouts
  module Carts
    def add_to_order
      Orders::Order.add(self)
    end
  end
end
```



### Testing pyramid

With this pattern how to test at the right level and amount is clearer.

For example:
Functional/integration style tests for each component will occur at the aggregate root level.
Unit tests occur for each individual class.

Boundary points for mocking/stubbing are at the aggregate root level.

Functional specs that cover cases touching sub domains are still tested at the aggregate root level.
As no application code is using objects without going through aggregate roots, no more
complex combinations of how to test objects need to be thought about.

The functional/integration specs sit at their corresponding location in the spec folder.

Example

```ruby
#app/concepts/checkouts.rb
module Checkouts
  def self.confirm_purchase(id)
  end
end

#spec/concepts/checkouts_integration_spec.rb
RSpec.describe Checkouts do
  describe ".confirm_purchase"
```

Sub module example

```ruby
#app/concepts/checkouts.rb
module Checkouts
  def self.add_to_cart(id)
    Carts.add(id)
  end
end

#app/concepts/checkouts.rb
module Checkouts
  module Carts
    def self.add(id)
      ::SomeOtherNamespace.do_a_thing!
    end
  end
end

#spec/concepts/checkouts/carts_integration_spec.rb
RSpec.describe Checkouts::Carts do
  before do
    # stub example
    allow(::SomeOtherNamespace).to receive(:do_a_thing!).and_return thing
  end

  let(:thing) { double("Some nice value object") }
  describe ".add"
    it do
      # mock example
      expect(::SomeOtherNamespace).to receive(:do_a_thing!).and_return thing
      expect(Checkouts::Carts.add(id)).to eq thing

```

In this example `SomeOtherNamespace` is very well tested and trusted, so we
don't need to actually execute it just to test some code in our own domain.


## Benefits, downsides, and alternatives

_Why is this the best option?_

It provides a lightweight structure for thinking about decoupling applications.
By sticking to this convention new work in the mononoth won't suffer anywhere near
as much from the spaghetti typically found in large Rails apps.

_What are the negatives of going with this design?_

It's not 'standard' Rails, so may be surprising when first encountering it.
It's a bit of overhead to add an aggregate root just to delegate through to
another object
The benefits become apparent over a longer period of time after initial
development and not immediately at the time of writing.

_What alternatives are there? Why should we not do those?_

* 1. Namespacing by nesting inside design pattern folders

Doing nested namespaces is really clunky when organising by design pattern.
Realising you need a new design pattern means having to make the awkward decision of
cluttering the top level app folder for everyone else with yet another folder.
Changing a design pattern e.g. presenter to decorator means unnecessarily moving a file
to a far away location on the file system.
Related code cannot be browsed/discovered easily.
We often find duplication in large applications because nobody realised another
piece of code existed which did the same thing.

```
app/services/checkouts/confirm_purchase.rb
app/models/checkouts/checkout.rb
app/presenters/checkouts/checkout_presenter.rb
app/decorators/checkouts/checkout_decorator.rb
app/decorators/checkouts/orders/order_decorator.rb
app/presenters/checkouts/orders/order_presenter.rb
```

* 2. Engines

Engines by default provide support for one level of namespacing
They are better for completely isolated functionality
They are harder to refactor between engine and host app/other engine etc.
You would still want a pattern like this proposal for sub-namespacing inside
an engine anyway.

There are complexities around:
 * deploy/release when in a separate repo
 * database migrations
 * gem dependencies

When nested inside the repo they don't add much benefit over this lighter weight
proposal.

Engines would be a good logical step *after* following this proposal and having
decoupled code

## Unresolved questions

- [ ] Frontend assets
- [ ] Specs

This is an approach I have used multiple times with positive results.
It brings some of the joy back to Rails development.

Whilst I have successfully colocated controllers and views I haven't used this approach for frontend assets etc.

In an ideal world I'd like to co-locate specs too, as golang does, but
there would be complexities around packaging up the app for deploys etc.

And as long as the specs follow the same filenaming conventions they are easy to find.

As it is just colocating and namespacing ruby files makes understanding and working with
Rails applications at least a magnitude easier.

