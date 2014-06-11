
# Public: A `Memoizable` object can store data resulting of heavy methods
# in order to speed up further call to that method.
#
# The invalidation of the memoized data is defined using a `memoizationKey`.
# That key should be generated based on the data that may induce changes
# in the functions's results.
#
# ```coffeescript
# class Dummy
#   @include mixins.Memoizable
#
#   constructor: (@p1, @p2) ->
#     # ...
#
#   heavyMethod: (arg) ->
#     key = "heavyMethod-#{arg}"
#     return @memoFor key if @memoized key
#
#     # do costly computation
#     @memoize key, result
#
#   memoizationKey: -> "#{p1};#{p2}"
# ```
class mixins.Memoizable
  # Public: Returns `true` if data are available for the given `prop`.
  #
  # When the current state of the object don't match the stored
  # memoization key, the whole data stored in the memo are cleared.
  #
  # prop - The {String} name of a property.
  #
  # Retuns a {Boolean} of whether the value of the propery is memoized or not.
  memoized: (prop) ->
    if @memoizationKey() is @__memoizationKey__
      @__memo__?[ prop ]?
    else
      @__memo__ = {}
      false

  # Public: Returns the memoized data for the given `prop`.
  #
  # prop - The {String} name of a property.
  #
  # Returns the memoized data for the given prop
  memoFor: (prop) -> @__memo__[ prop ]

  # Public: Register a memo in the current object for the given `prop`.
  # The memoization key is updated with the current state of the
  # object.
  memoize: (prop, value) ->
    @__memo__ ||= {}
    @__memoizationKey__ = @memoizationKey()
    @__memo__[ prop ] = value

  # Public: Abstract: Generates the memoization key for this instance's state.
  #
  # By default the memoization key of an object is the return of its `toString`
  # method. **You SHOULD redefine the memoization key generation in the class
  # including the `Memoizable` mixin.**
  #
  # Returns a {String} that identify the state of the current instance.
  memoizationKey: -> @toString()
