### Public ###

# Creates a new non-enumerable method on the current class prototype.
#
# ```coffeescript
# class Dummy
#   @def 'method', ->
# ```
#
# name - The {String} for the method name.
# block - The {Function} body.
Function::def = (name, block) ->
  Object.defineProperty @prototype, name, {
    value: block
    configurable: true
    enumerable: false
  }
  this

# Creates a virtual property on the current class's prototype.
#
# ```coffeescript
# class Dummy
#   @accessor 'foo', {
#     get: -> @fooValue * 2
#     set: (value) -> @fooValue = value / 2
#   }
#
# dummy = new Dummy
# dummy.foo = 10
# dummy.fooValue # 5
# dummy.foo      # 10
# ```
#
# name - The {String} for the accessor name.
# options - A descriptor {Object} for the accessor. It can contains
#           the following properties:
#           get - A {Function} to read the property's value.
#           set - A {Function} to write the property's value.
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

# Creates a getter on the given class prototype.
#
# ```coffeescript
# class Dummy
#   @getter 'foo', -> 'bar'
# ```
#
# name - The {String} name of the property accessor to create.
# block - The {Function} to read the property value.
Function::getter = (name, block) -> @accessor name, get: block

# Creates a setter on the given class prototype.
#
# ```coffeescript
# class Dummy
#   @setter 'foo', (value) -> @fooValue = value / 2
# ```
#
# name - The {String} name of the property accessor to create.
# block - The {Function} to write the property value.
Function::setter = (name, block) -> @accessor name, set: block

# Internal: Registers a method as the super method for another method
# for the given class. The super methods are stored in a map structure
# where the `__included__` array stores the keys and the `__super__`
# array stores the values. A meaningful name is added to the function
# to know its origin.
#
# key - The {String} name of the field that is being manipulated.
# value - A {Function} that will be set as the new value of the field.
# klass - The {Function} that is or has its prototype being manipulated.
# sup - The {Function} that is actually stored in the manipulated field
#       and that is going to become the super method of the passed-in `value`.
# mixin - The {Function} mixin that is currently decorating the target class.
registerSuper = (key, value, klass, sup, mixin) ->
  return if value.__included__? and klass in value.__included__

  value.__super__ ||= []
  value.__super__.push sup

  value.__included__ ||= []
  value.__included__.push klass

  value.__name__ = "#{mixin.name}::#{key}"

# Injects the properties from the mixin in the `mixins` {Array}
# into the target prototype.
#
#
# ```coffeescript
# class Mixin
#   instanceMethod: -> 'in the instance'
#
# class Dummy
#   @include Mixin
#
# dummy = new Dummy
# dummy.instanceMethod() # 'in the instance'
# ```
#
# ```coffeescript
# class Dummy
#   @include MixinA, MixinB, MixinC
# ```
#
# mixins - A list of `Mixin` to include in the class.
Function::include = (mixins...) ->

  # The mixins prototype constructor and excluded properties
  # are always excluded.
  excluded = ['constructor', 'excluded', 'super']

  # Internal: Stores the mixins included in the current class.
  @__mixins__ ||= []

  # Internal: Stores the parent class prototype when the `extend`
  # keyword is used. It also stores mixins methods when the class doesn't
  # extend another class.
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
    # prototype that is not marked for exclusion.
    keys = Object.keys mixin.prototype
    for k in keys
      if k not in excl

        # We prefer working with property descriptors rather than with
        # the plain values.
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

# Extends the current class with the properties of the passed-in
# `mixins`.
#
# ```coffeescript
# class Mixin
#   @classMethod: -> 'in the class'
#
# class Dummy
#   @extend Mixin
#
# Dummy.classMethod() # 'in the class'
# ```
#
# mixins - A list of `Mixin` to extend this class.
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

# Combinates `Function::include` and `Function::extend` into
# one function.
#
# ```coffeescript
# class Mixin
#   @classMethod: -> 'in class method'
#   instanceMethod: -> 'in instance method'
#
# class Dummy
#   @concern Mixin
#
# Dummy.classMethod() # 'in class method'
# dummy = new Dummy
# dummy.instanceMethod() # 'in instance method'
# ```
#
# mixins - A list of `Mixin` that concern the class.
Function::concern = (mixins...) ->
  @include.apply(this, mixins)
  @extend.apply(this, mixins)
