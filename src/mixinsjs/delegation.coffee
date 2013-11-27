class mixins.Delegation
  @delegate: (properties..., options={}) ->
    delegated = options.to
    prefixed = options.prefix
    _case = options.case or 'camel'

    properties.forEach (property) =>
      localAlias = property
      if prefixed
        switch _case
          when 'snake'
            localAlias = delegated + '_' + property
          when 'camel'
            localAlias = delegated + property.replace /^./, (m) ->
              m.toUpperCase()

      Object.defineProperty @prototype, localAlias, {
        enumerable: true
        configurable: true
        get: -> @[delegated][property]
        set: (value) -> @[delegated][property] = value
      }
