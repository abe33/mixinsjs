# @toc
Mixin = require './mixin'

## Equatable

# An `Equatable` object can be compared in equality with another object.
# Objects are considered as equals if all the listed properties are equal.
#
#     class Dummy
#       Equatable('p1', 'p2').attachTo Dummy
#
#       constructor: (@p1, @p2) ->
#         # ...
#
#     dummy = new Dummy(10, 'foo')
#     dummy.equals p1: 10, p2: 'foo'   # true
#     dummy.equals new Dummy(5, 'bar') # false
#
# The `Equatable` mixin is called a parameterized mixin as
# it's in fact a function that will generate a mixin based
# on its arguments.
Equatable = (properties...) ->

  # A concrete class is generated and returned by `Equatable`.
  # This class extends `Mixin` and can be attached as any other
  # mixin with the `attachTo` method.
  class ConcreteEquatable extends Mixin
    ##### Equatable.attachTo
    #
    # See [Mixin.attachTo](src_geomjs_mixins_mixin.html#mixinattachto)

    ##### Equatable::equals
    #
    # Compares the `properties` of the passed-in object with the current
    # object and return `true` if all the values are equal.
    equals: (o) -> o? and properties.every (p) =>
      if @[p].equals? then @[p].equals o[p] else o[p] is @[p]

module.exports = Equatable
