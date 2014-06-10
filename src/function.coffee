Function::def = (name, block) ->
  Object.defineProperty @prototype, name, {
    value: block
    configurable: true
    enumerable: false
  }
  this

# Public: Creates a virtual property on the current class's prototype.
#
# ```coffeescript
# class Dummy
# @accessor 'foo', {
# get: -> @fooValue * 2
# set: (value) -> @fooValue = value / 2
# }
#
# dummy = new Dummy
# dummy.foo = 10
# dummy.fooValue # 5
# dummy.foo      # 10
# ```
Function::accessor = (name, options) ->
  oldDescriptor = Object.getPropertyDescriptor @prototype, name

  options.get ||= oldDescriptor.get if oldDescriptor?
  options.set ||= oldDescriptor.set if oldDescriptor?

  Object.defineProperty @prototype, name, {
    get: options.get
    set: options.set
    configurable: true
    enumerable: true
  }
  this

# Public: Creates a getter on the given class prototype
#
# ```coffeescript
# class Dummy
# @getter 'foo', -> 'bar'
# ```
Function::getter = (name, block) -> @accessor name, get: block

# Creates a setter on the given class prototype
#
# ```coffeescript
# class Dummy
# @setter 'foo', (value) -> @fooValue = value / 2
# ```
Function::setter = (name, block) -> @accessor name, set: block

# This method registers a method as the super method for another
# method for the given class.
# The super methods are stored in a map structure where the `__included__`
# array stores the keys and the `__super__` array stores the values.
# A meaningful name is added to the function to know its origin.
registerSuper = (key, value, klass, sup, mixin) ->
  return if value.__included__? and klass in value.__included__

  value.__super__ ||= []
  value.__super__.push sup

  value.__included__ ||= []
  value.__included__.push klass

  value.__name__ = "#{mixin.name}::#{key}"

##### Function::include
#
# The `include` method inject the properties from the mixins
# prototype into the target prototype.
Function::include = (mixins...) ->

  # The mixins prototype constructor and excluded properties
  # are always excluded.
  excluded = ['constructor', 'excluded', 'super']

  # The `__mixins__` class property will stores the mixins included
  # in the current class.
  @__mixins__ ||= []

  # The `__super__` class property is used in CoffeeScript to store
  # the parent class prototype when the `extend` keyword is used.
  #
  # It'll be used to store the super methods from mixins so we create
  # one to use as default if we can't find it.
  @__super__ ||= {}

  # We create a new `__super__` using the previous one as prototype.
  # It allow to have mixins overrides some properties already defined
  # by a parent prototype without actually modifying this prototype.
  @__super__ = Object.create @__super__

  # For each mixin passed to the `include` class method:
  # We'll store the mixin in the `__mixins__` array to keep track of
  # its inclusion.
  for mixin in mixins
    @__mixins__.push mixin

    # A new Array is created to store the exclusion list of the current
    # mixin. It is based on the default exclusion array.
    excl = excluded.concat()
    excl = excl.concat mixin::excluded if mixin::excluded?

    # We loop through all the enumerable properties of the mixin's
    # prototype.
    keys = Object.keys mixin.prototype
    for k in keys
      if k not in excl

        # We prefer working with property descriptors rather than with
        # the plain value.
        oldDescriptor = Object.getPropertyDescriptor @prototype, k
        newDescriptor = Object.getPropertyDescriptor mixin.prototype, k

        # If the two descriptors are available we'll have to go deeper.
        if oldDescriptor? and newDescriptor?
          oldHasAccessor = oldDescriptor.get? or oldDescriptor.set?
          newHasAccessor = newDescriptor.get? or newDescriptor.set?
          bothHaveGet = oldDescriptor.get? and newDescriptor.get?
          bothHaveSet = oldDescriptor.set? and newDescriptor.set?
          bothHaveValue = oldDescriptor.value? and newDescriptor.value?

          # When both properties are accessors we'll be able to follow
          # the super accross them.
          #
          # Super methods are registered if both are there for getters
          # and setters.
          if oldHasAccessor and newHasAccessor
            registerSuper k, newDescriptor.get, @, oldDescriptor.get, mixin if bothHaveGet
            registerSuper k, newDescriptor.set, @, oldDescriptor.set, mixin if bothHaveSet

            # If there was a getter or a setter and the new accessor
            # doesn't define one them, the previous value is used.
            newDescriptor.get ||= oldDescriptor.get
            newDescriptor.set ||= oldDescriptor.set

          # When both have a value, the super is also available.
          else if bothHaveValue
            registerSuper k, newDescriptor.value, @, oldDescriptor.value, mixin

          else
            throw new Error "Can't mix accessors and plain values inheritance"

          # We also have to create the property on the class `__super__`
          # property. It'll allow the method defined on the class itself
          # and overriding the property to have access to its super property
          # through the `super` keyword or with `this.super` method.
          Object.defineProperty @__super__, k, newDescriptor

        # We only have a descriptor for the new property, the previous
        # one is just added to the class `__super__` property.
        else if newDescriptor?
          @__super__[k] = mixin[k]

        # We only have a descriptor for the previous property, we'll
        # create it on the class `__super__` property.
        else if oldDescriptor?
          Object.defineProperty @__super__, k, newDescriptor

        # No descriptors at all. The super property is attached directly
        # to the value.
        else if @::[k]?
          registerSuper k, mixin[k], @, @::[k], mixin
          @__super__[k] = mixin[k]

        # With a descriptor the new property is created using
        # `Object.defineProperty` or by affecting the value
        # to the prototype.
        if newDescriptor?
          Object.defineProperty @prototype, k, newDescriptor
        else
          @::[k] = mixin::[k]

    # The `included` hook is triggered on the mixin.
    mixin.included? this

  this

##### Function::extend

Function::extend = (mixins...) ->
  excluded = ['extended', 'excluded', 'included']

  # The `__mixins__` class property will stores the mixins included
  # in the current class.
  @__mixins__ ||= []

  for mixin in mixins
    @__mixins__.push mixin

    excl = excluded.concat()
    excl = excl.concat mixin.excluded if mixin.excluded?

    keys = Object.keys mixin
    for k in keys
      if k not in excl
        oldDescriptor = Object.getPropertyDescriptor this, k
        newDescriptor = Object.getPropertyDescriptor mixin, k

        if oldDescriptor? and newDescriptor?
          oldHasAccessor = oldDescriptor.get? or oldDescriptor.set?
          newHasAccessor = newDescriptor.get? or newDescriptor.set?
          bothHaveGet = oldDescriptor.get? and newDescriptor.get?
          bothHaveSet = oldDescriptor.set? and newDescriptor.set?
          bothHaveValue = oldDescriptor.value? and newDescriptor.value?

          # When both properties are accessors we'll be able to follow
          # the super accross them
          #
          # Super methods are registered if both are there for getters
          # and setters.
          if oldHasAccessor and newHasAccessor
            registerSuper k, newDescriptor.get, @, oldDescriptor.get, mixin if bothHaveGet
            registerSuper k, newDescriptor.set, @, oldDescriptor.set, mixin if bothHaveSet

            # If there was a getter or a setter and the new accessor
            # doesn't define one them, the previous value is used.
            newDescriptor.get ||= oldDescriptor.get
            newDescriptor.set ||= oldDescriptor.set

          # When both have a value, the super is also available.
          else if bothHaveValue
            registerSuper k, newDescriptor.value, @, oldDescriptor.value, mixin

          else
            throw new Error "Can't mix accessors and plain values inheritance"

        # With a descriptor the new property is created using
        # `Object.defineProperty` or by affecting the value
        # to the prototype.
        if newDescriptor?
          Object.defineProperty this, k, newDescriptor
        else
          @[k] = mixin[k]

    mixin.extended? this

  this

Function::concern = (mixins...) ->
  @include.apply(this, mixins)
  @extend.apply(this, mixins)
