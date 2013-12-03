
# A `Memoizable` object can store data resulting of heavy methods
# in order to speed up further call to that method.
#
# The invalidation of the memoized data is defined using a `memoizationKey`.
# That key should be generated based on the data that may induce changes
# in the functions's results.
#
#     class Dummy
#       @include mixins.Memoizable
#
#       constructor: (@p1, @p2) ->
#         # ...
#
#       heavyMethod: (arg) ->
#         key = "heavyMethod-#{arg}"
#         return @memoFor key if @memoized key
#
#         # do costly computation
#         @memoize key, result
#
#       memoizationKey: -> "#{p1};#{p2}"
class mixins.Memoizable
  ##### Memoizable::memoized
  #
  # Returns `true` if data are available for the given `prop`.
  #
  # When the current state of the object don't match the stored
  # memoization key, the whole data stored in the memo are cleared.
  memoized: (prop) ->
    if @memoizationKey() is @__memoizationKey__
      @__memo__?[prop]?
    else
      @__memo__ = {}
      false

  ##### Memoizable::memoFor
  #
  # Returns the memoized data for the given `prop`.
  memoFor: (prop) -> @__memo__[prop]

  ##### Memoizable::memoize
  #
  # Register a memo in the current object for the given `prop`.
  # The memoization key is updated with the current state of the
  # object.
  memoize: (prop, value) ->
    @__memo__ ||= {}
    @__memoizationKey__ = @memoizationKey()
    @__memo__[prop] = value

  ##### Memoizable::memoizationKey
  #
  # **Virtual Method**
  #
  # Generates the memoization key for this instance's state.
  memoizationKey: -> @toString()

