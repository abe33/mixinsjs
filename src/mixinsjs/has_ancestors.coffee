mixins.HasAncestors = (options={}) ->
  through = options.through or 'parent'

  class ConcreteHasAncestors
    @getter 'ancestors', ->
      ancestors = []
      parent = @[ through ]

      while parent?
        ancestors.push parent
        parent = parent[ through ]

      ancestors

    @getter 'selfAndAncestors', -> [ this ].concat @ancestors

    @ancestorsScope: (name, block) ->
      @getter name, -> @ancestors.filter(block, this)

mixins.HasAncestors._name = 'HasAncestors'
