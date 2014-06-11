
# Public: The `HasCollection` mixin provides methods to expose a collection
# in a class. The mixin is created using two strings.
#
# ```coffeescript
# class Dummy
#   @concern mixins.HasCollection 'children', 'child'
#
#   constructor: ->
#     @children = []
# ```
#
# The `plural` string is used to access the collection in all methods
# provided by the mixin. The `singular` string will be used to create
# the collection managing methods.
#
# For instance, given that `'children'` and `'child'` was passed as arguments
# to `HasCollection` the following methods and properties will be created:
#
# - `childrenSize` [getter]
# - `childrenCount` [getter]
# - `childrenLength` [getter]
# - `hasChildren` [getter]
# - `addChild`
# - `removeChild`
# - `hasChild`
# - `containsChild`
#
# plural - The {String} name of the property where the collection can be found.
# singular - The singularized {String} name.
#
# Returns a {ConcreteHasCollection} mixin.
mixins.HasCollection = (plural, singular) ->

  pluralPostfix = plural.replace /^./, (s) -> s.toUpperCase()
  singularPostfix = singular.replace /^./, (s) -> s.toUpperCase()

  # Public: The concrete mixin as returned by the
  # [HasCollection](../files/mixins/has_collection.coffee.html) generator.
  class ConcreteHasCollection
    # The mixin integrates `Aliasable` to create various alias to the
    # collection methods.
    @extend mixins.Aliasable

    # Public: Creates a `name` scope on instances that filter
    # the collection using the passed-in `block`.
    #
    # name - The {String} name of the collection scope.
    # block - The {Function} filter for the scope.
    @[ "#{ plural }Scope" ] = (name, block) ->
      @getter name, -> @[ plural ].filter block, this

    # Public: A property returning the number of elements in the collection.
    @getter "#{ plural }Size", -> @[ plural ].length

    # Creates aliases for the collection size property.
    @alias "#{ plural }Size", "#{ plural }Length", "#{ plural }Count"

    # Public: Returns `true` if the passed-in `item` is present
    # in the collection.
    #
    # item - The item {Object} to search in the collection.
    #
    # Returns a {Boolean} of whether the item is present
    # in the collection or not.
    @::[ "has#{ singularPostfix }" ] = (item) -> item in @[ plural ]

    # Creates an alias for `has<Item>` named `contains<Item>`.
    @alias "has#{ singularPostfix }", "contains#{ singularPostfix }"

    # Public: Returns `true` if the collection has at least one item.
    #
    # Returns a {Boolean} of whether the collection has items or not.
    @getter "has#{ pluralPostfix }", -> @[ plural ].length > 0

    # Public: Adds `item` in the collection unless it's already present.
    #
    # item - The item {Object} to append to the collection.
    #
    # Returns the {Number} of items in the collection.
    @::[ "add#{ singularPostfix }" ] = (item) ->
      @[ plural ].push item unless @[ "has#{ singularPostfix }" ] item
      @[ "#{ plural }Size" ]

    # Public: Removes `item` from the collection.
    #
    # item - The item {Object} to remove from the collection.
    #
    # Returns the {Number} of items in the collection.
    @::[ "remove#{ singularPostfix }" ] = (item) ->
      if @[ "has#{ singularPostfix }" ] item
        @[ plural ].splice @[ "find#{ singularPostfix }" ](item), 1
      @[ "#{ plural }Size" ]

    # Public: Returns the index at which `item` is stored
    # in the collection. It returns `-1` if `item` can't be found.
    #
    # item - The item {Object} to search in the collection.
    #
    # Returns the index {Number} of the passed-in item or `-1`.
    @::[ "find#{ singularPostfix }" ] = (item) -> @[ plural ].indexOf item

    # Creates an alias for `find<Item>` named `indexOf<Item>`
    @alias "find#{ singularPostfix }", "indexOf#{ singularPostfix }"
