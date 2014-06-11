
# Public: The `HasNestedCollection` adds a property with named `name`
# that collects and concatenates all the descendants collections
# into a single array.
# It operates on classes that already includes the `HasCollection` mixin.
#
# ```coffeescript
# class Dummy
#   @concern mixins.HasCollection 'children', 'child'
#   @concern mixins.HasNestedCollection 'descendants', through: 'children'
#
#   constructor: ->
#     @children = []
# ```
#
# name - The {String} name of the nested collection accessor.
# options - The options {Object}:
#           :through - The {String} name of the collection accessor
#                      to collect on the collection items the nested
#                      collections.
#
# Returns a {ConcreteHasNestedCollection} mixin.
mixins.HasNestedCollection = (name, options={}) ->

  # The collection is accessed with the named passed in the `through`option.
  through = options.through
  throw new Error('missing through option') unless through?

  # Public: The concrete mixin as returned by the
  # [HasNestedCollection](../files/mixins/has_nested_collection.coffee.html)
  # generator.
  class ConcreteHasNestedCollection

    # Public: Creates a property on instances that filters the nested
    # collections items using the passed-in `block`.
    #
    # scopeName - The {String} name for the scope.
    # block - The {Function} filter of the scope.
    @[ "#{ name }Scope" ] = (scopeName, block) ->
      @getter scopeName, -> @[ name ].filter block, this

    # Public: Returns a flat array containing all the items contained
    # in all the nested collections.
    @getter name, ->
      items = []
      @[ through ].forEach (item) ->
        items.push(item)
        items = items.concat(item[ name ]) if item[ name ]?
      items
