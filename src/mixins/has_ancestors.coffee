
# The `HasAncestors` mixin adds several methods to instance to deal
# with parents and ancestors.
#
#     class Dummy
#       @concern mixins.HasAncestors through: 'parentNode'
#
# The `through` option allow to specify the property name that access
# to the parent.
mixins.HasAncestors = (options={}) ->
  through = options.through or 'parent'

  class ConcreteHasAncestors
    ##### HasAncestors::ancestors
    #
    # Returns an array of all the ancestors of the current object.
    # The ancestors are ordered such as the first element is the direct
    # parent of the current object.
    @getter 'ancestors', ->
      ancestors = []
      parent = @[ through ]

      while parent?
        ancestors.push parent
        parent = parent[ through ]

      ancestors

    ##### HasAncestors::selfAndAncestors
    #
    # Returns an object containing the current object followed by its
    # parent and ancestors.
    @getter 'selfAndAncestors', -> [ this ].concat @ancestors

    ##### HasAncestors.ancestorsScope
    #
    # Defines a getter property on instances named with `name` and that
    # filter the `ancestors` array with the given `block`.
    @ancestorsScope: (name, block) ->
      @getter name, -> @ancestors.filter(block, this)

mixins.HasAncestors._name = 'HasAncestors'
