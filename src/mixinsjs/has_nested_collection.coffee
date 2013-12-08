
# The `HasNestedCollection` adds a property with named `name` that
# collects and concatenates all the descendants collections into a
# single array.
# It operates on classes that already includes the `HasCollection` mixin.
#
#     class Dummy
#       @concern mixins.HasCollection 'children', 'child'
#       @concern mixins.HasNestedCollection 'descendants', through: 'children'
#
#       constructor: ->
#         @children = []
#
mixins.HasNestedCollection = (name, options={}) ->

  # The collection is accessed with the named passed in the `through`option.
  through = options.through
  throw new Error('missing through option') unless through?

  class ConcreteHasNestedCollection
    ##### HasNestedCollection::<name>Scope
    #
    # Creates a property on instances that filters the nested collections
    # items using the passed-in `block`.
    @[ "#{ name }Scope" ] = (scopeName, block) ->
      @getter scopeName, -> @[ name ].filter block, this

    ##### HasCollection::<name>
    #
    # Returns a flat array containing all the items contained in all the
    # nested collections.
    @getter name, ->
      items = []
      @[ through ].forEach (item) ->
        items.push(item)
        items = items.concat(item[ name ]) if item[ name ]?
      items

mixins.HasNestedCollection._name = 'HasNestedCollection'

