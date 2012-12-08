# @toc
Mixin = require './mixin'

## Cloneable

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

Cloneable = (properties...) ->
  class ConcreteCloneable extends Mixin
    @included: if properties.length is 0
      (klass) -> klass::clone = -> new klass this
    else
      (klass) -> klass::clone = -> build klass, properties.map (p) => @[p]

module.exports = Cloneable
