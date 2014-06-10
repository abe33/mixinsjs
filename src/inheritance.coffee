
# Internal: For a given function on an object it will find the property
# name and its kind (value/getter/setter).
findCaller = (caller, proto) ->
  keys = Object.keys proto

  for k in keys
    descriptor = Object.getPropertyDescriptor proto, k

    if descriptor?
      return {key: k, descriptor, kind: 'value'} if descriptor.value is caller
      return {key: k, descriptor, kind: 'get'} if descriptor.get is caller
      return {key: k, descriptor, kind: 'set'} if descriptor.set is caller
    else
      return {key: k} if proto[k] is caller

  {}

unless Object::super?
  # Public: Gives access to the super method of any 
  Object.defineProperty Object.prototype, 'super', {
    enumerable: false
    configurable: true
    value: (args...) ->
      # To define which function to use as super when
      # calling the `this.super` method we need to know which
      # function is the caller.
      caller = arguments.caller ? @super.caller
      if caller?
        # When the caller has a `__super__` property, we face
        # a mixin method, we can access the `__super__` property
        # to retrieve its super property.
        if caller.__super__?
          value = caller.__super__[caller.__included__.indexOf @constructor]

          # The `this.super` method can be called only if the super
          # is a function.
          if value?
            if typeof value is 'function'
              value.apply(this, args)
            else
              throw new Error "The super for #{caller._name} isn't a function"
          else
            throw new Error "No super method for #{caller._name}"

        # Without the `__super__` property we face a method declared
        # in the including class and that may redefine a method from
        # a mixin or a parent.
        else
          # The name of the property that stores the caller is retrieved.
          # The `kind` variable is either `'value'`, `'get'`, `'set'`
          # or `'null'`. It will be needed to find the correspondant
          # super method in the property descriptor.
          {key, kind} = findCaller caller, @constructor.prototype

          # If the key is present we'll try to get a descriptor on the
          # `__super__` class property.
          if key?
            desc = Object.getPropertyDescriptor @constructor.__super__, key

            # And if a descriptor is available we get the function
            # corresponding to the `kind` and call it with the arguments.
            if desc?
              value = desc[kind].apply(this, args)

            # Otherwise, the value of the property is simply called.
            else
              value = @constructor.__super__[key].apply(this, args)

            return value

          # And in other cases an error is raised.
          else
            throw new Error "No super method for #{caller.name || caller._name}"
      else
        throw new Error "Super called with a caller"

  }

  # Public:
  Object.defineProperty Function.prototype, 'super', {
    enumerable: false
    configurable: true
    value: (args...) ->
      caller = arguments.caller or @super.caller
      if caller?
        if caller.__super__?
          value = caller.__super__[caller.__included__.indexOf this]

          if value?
            if typeof value is 'function'
              value.apply(this, args)
            else
              throw new Error "The super for #{caller._name} isn't a function"
          else
            throw new Error "No super method for #{caller._name}"

        else
          # super method in the property descriptor.
          {key, kind} = findCaller caller, this

          reverseMixins = []
          reverseMixins.unshift m for m in @__mixins__

          # If the key is present we'll try to get a descriptor on the
          # `__super__` class property.
          if key?
            for m in reverseMixins
              if m[key]?
                mixin = m
                break

            desc = Object.getPropertyDescriptor mixin, key

            # And if a descriptor is available we get the function
            # corresponding to the `kind` and call it with the arguments.
            if desc?
              value = desc[kind].apply(this, args)

            # Otherwise, the value of the property is simply called.
            else
              value = mixin[key].apply(this, args)

            return value

          # And in other cases an error is raised.
          else
            throw new Error "No super class method for #{caller.name || caller._name}"
      else
        throw new Error "super called without a caller"

  }
