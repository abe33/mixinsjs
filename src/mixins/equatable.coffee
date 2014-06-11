
# Public: An `Equatable` object can be compared in equality with another object.
# Objects are considered as equal if all the listed properties are equal.
#
# ```coffeescript
# class Dummy
#   @include mixins.Equatable('p1', 'p2')
#
#   constructor: (@p1, @p2) ->
#     # ...
#
# dummy = new Dummy(10, 'foo')
# dummy.equals p1: 10, p2: 'foo'   # true
# dummy.equals new Dummy(5, 'bar') # false
# ```
#
# The `Equatable` mixin is called a parameterized mixin as
# it's in fact a function that will generate a mixin based
# on its arguments.
#
# properties - A list of {String} of the properties to compare to set equality.
#
# Returns a {ConcreteEquatable} mixin.
mixins.Equatable = (properties...) ->

  # Public: A concrete mixin is generated and returned by the
  # [Equatable](../files/mixins/equatable.coffee.html) generator.
  class ConcreteEquatable

    # Public: Compares the `properties` of the passed-in object with the current
    # object and return `true` if all the values are equal.
    #
    # o - The {Object} to compare to this instance.
    #
    # Returns a {Boolean} of whether the objects are equal or not.
    equals: (o) -> o? and properties.every (p) =>
      if @[ p ].equals? then @[ p ].equals o[ p ] else o[p] is @[ p ]
