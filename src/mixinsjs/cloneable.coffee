
#### Build

# Contains all the function that will instanciate a class with a specific
# number of arguments. These functions are all generated at runtime with
# the `Function` constructor.
BUILDS = (
  new Function( "return new arguments[0](#{
    ("arguments[1][#{j-1}]" for j in [0..i] when j isnt 0 ).join ","
  });") for i in [0..24]
)

build = (klass, args) ->
  f = BUILDS[if args? then args.length else 0]
  f klass, args

#### Cloneable

# A `Cloneable` object can return a copy of itself through the `clone`
# method.
#
# The `Cloneable` function produce a different mixin when called
# with or without arguments.
#
# When called without argument, the returned mixin creates a clone using
# a copy constructor (a constructor that initialize the current object
# with an object).
#
#     class Dummy
#       @include mixins.Cloneable()
#
#       constructor: (options={}) ->
#         @property = options.property or 'foo'
#         @otherProperty = options.otherProperty or 'bar'
#
#     instance = new Dummy
#     otherInstance = instance.clone()
#     # otherInstance = {property: 'foo', otherProperty: 'bar'}
#
# When called with arguments, the `clone` method will call the class
# constructor with the values extracted from the given properties.
#
#     class Dummy
#       @include mixins.Cloneable('property', 'otherProperty')
#
#       constructor: (@property='foo', @otherProperty='bar') ->
#
#     instance = new Dummy
#     otherInstance = instance.clone()
#     # otherInstance = {property: 'foo', otherProperty: 'bar'}
mixins.Cloneable = (properties...) ->
  class ConcreteCloneable
    if properties.length is 0
      @included: (klass) -> klass::clone = -> new klass this
    else
      @included: (klass) -> klass::clone = -> build klass, properties.map (p) => @[p]

mixins.Cloneable._name = 'Cloneable'
