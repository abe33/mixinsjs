
# The `HasCollection` mixin provides methods to expose a collection
# in a class. The mixin is created using two strings.
#
#     class Dummy
#       @concern mixins.HasCollection 'children', 'child'
#
#       constructor: ->
#         @children = []
#
# The `plural` string is used to access the collection in all methods
# provided by the mixin. The `singular` string will be used to create
# the collection managing methods.
#
# For instance, given that `'children'` and `'child'` was passed as arguments
# to `HasCollection` the following methods and properties will be created:
#
#    - childrenSize [getter]
#    - childrenCount [getter]
#    - childrenLength [getter]
#    - hasChildren [getter]
#    - addChild
#    - removeChild
#    - hasChild
#    - containsChild
mixins.HasCollection = (plural, singular) ->

  pluralPostfix = plural.replace /^./, (s) -> s.toUpperCase()
  singularPostfix = singular.replace /^./, (s) -> s.toUpperCase()

  class ConcreteHasCollection
    # The mixin integrates `Aliasable` to create various alias to the
    # collection methods.
    @extend mixins.Aliasable

    ##### HasCollection.&lt;items&gt;Scope
    #
    # Creates a `name` property on instances that filter the collection
    # using the passed-in `block`.
    @[ "#{ plural }Scope" ] = (name, block) ->
      @getter name, -> @[ plural ].filter block, this

    ##### HasCollection::&lt;items&gt;Size
    #
    # A property returning the number of elements in the collection.
    @getter "#{ plural }Size", -> @[ plural ].length

    # Creates aliases for the collection size property.
    @alias "#{ plural }Size", "#{ plural }Length", "#{ plural }Count"

    ##### HasCollection::has&lt;Item&gt;
    #
    # Returns `true` if the passed-in `item` is present in the collection.
    @::[ "has#{ singularPostfix }" ] = (item) -> item in @[ plural ]

    # Creates an alias for `has<Item>` named `contains<Item>`.
    @alias "has#{ singularPostfix }", "contains#{ singularPostfix }"

    ##### HasCollection::has&lt;Items&gt;
    #
    # Returns `true` if the collection has at least one item.
    @getter "has#{ pluralPostfix }", -> @[ plural ].length > 0

    ##### HasCollection::add&lt;Item&gt;
    #
    # Adds `item` in the collection unless it's already present.
    @::[ "add#{ singularPostfix }" ] = (item) ->
      @[ plural ].push item unless @[ "has#{ singularPostfix }" ] item

    ##### HasCollection::remove&lt;Item&gt;
    #
    # Removes `item` from the collection.
    @::[ "remove#{ singularPostfix }" ] = (item) ->
      if @[ "has#{ singularPostfix }" ] item
        @[ plural ].splice @[ "find#{ singularPostfix }" ](item), 1

    ##### HasCollection::find&lt;Item&gt;
    #
    # Retuns the index at which `item` is stored in the collection.
    # It returns `-1` if `item` can't be found.
    @::[ "find#{ singularPostfix }" ] = (item) -> @[ plural ].indexOf item

    # Creates an alias for `find<Item>` named `indexOf<Item>`
    @alias "find#{ singularPostfix }", "indexOf#{ singularPostfix }"

mixins.HasCollection._name = 'HasCollection'
