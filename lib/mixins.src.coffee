# The module bootstrap.
isCommonJS = typeof module isnt "undefined"

if isCommonJS
  exports = module.exports or {}
else
  exports = window.mixins = {}

mixins = exports

mixins.version = '1.0.1'

mixins.CAMEL_CASE = 'camel'
mixins.SNAKE_CASE = 'snake'

mixins.deprecated = (message) ->
  parseLine = (line) ->
    if line.indexOf('@') > 0
      if line.indexOf('</') > 0
        [m, o, f] = /<\/([^@]+)@(.)+$/.exec line
      else
        [m, f] = /@(.)+$/.exec line
    else
      if line.indexOf('(') > 0
        [m, o, f] = /at\s+([^\s]+)\s*\(([^\)])+/.exec line
      else
        [m, f] = /at\s+([^\s]+)/.exec line

    [o,f]

  e = new Error()
  caller = ''
  if e.stack?
    s = e.stack.split('\n')
    [deprecatedMethodCallerName, deprecatedMethodCallerFile] = parseLine s[3]

    caller = if deprecatedMethodCallerName
      " (called from #{deprecatedMethodCallerName} at #{deprecatedMethodCallerFile})"
    else
       "(called from #{deprecatedMethodCallerFile})"

  console.log "DEPRECATION WARNING: #{message}#{caller}"

mixins.deprecated._name = 'deprecated'

unless Object.getPropertyDescriptor?
  if Object.getPrototypeOf? and Object.getOwnPropertyDescriptor?
    Object.getPropertyDescriptor = (o, name) ->
      proto = o
      descriptor = undefined
      proto = Object.getPrototypeOf?(proto) or proto.__proto__ while proto and not (descriptor = Object.getOwnPropertyDescriptor(proto, name))
      descriptor
  else
    Object.getPropertyDescriptor = -> undefined

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

# Public: The `Activable` mixin provides the basic interface for an activable
# widget. You can hook your own activation/deactivation routines by overriding
# the `activated` and `deactivated` methods.
#
# ```coffeescript
# class Dummy
#   @include mixins.Activable
#
#   activated: ->
#     # ...
#
#   deactivated: ->
#     # ...
# ```
#
# `Activable` instances are deactivated at creation.
class mixins.Activable
  active: false

  # Public: Activates the instance.
  activate: ->
    return if @active
    @active = true
    @activated?()

  # Public: Deactivates the instance.
  deactivate: ->
    return unless @active
    @active = false
    @deactivated?()


# Public: Provides class methods to deal with aliased methods and properties.
#
# ```coffeescript
# class Dummy
#   @extend mixins.Aliasable
#
#   someMethod: ->
#   @alias 'someMethod', 'someMethodAlias'
# ```
class mixins.Aliasable

  # Public: Creates aliases for the given `source` property of tthe current
  # class prototype. Any number of alias can be passed at once.
  #
  # source - The {String} name of the aliased property
  # aliases - A list of {String}s to use as aliases.
  @alias: (source, aliases...) ->
    desc = Object.getPropertyDescriptor @prototype, source

    if desc?
      Object.defineProperty @prototype, alias, desc for alias in aliases
    else
      if @prototype[ source ]?
        @prototype[ alias ] = @prototype[ source ] for alias in aliases


# Public: The `AlternateMixin` mixin add methods to convert the properties
# of a class instance to camelCase or snake_case.
#
# The methods are available on the class itself and should be called
# after having declared all the class members.
#
# For instance, given the class below:
#
# ```coffeescript
# class Dummy
#   @extend mixins.AlternateCase
#
#   someProperty: 'foo'
#   someMethod: ->
#
#   @snakify()
# ```
#
# An instance will have both `someProperty` and `someMethod` as defined
# by the class, but also `some_property` and `some_method`.
#
# The alternative is also possible. Given a class that uses snake_case
# to declare its member, the `camelize` method will provides the camelCase
# alternative to the class.
class mixins.AlternateCase

  # Public: Converts all the prototype properties to snake_case.
  @snakify: -> @convert 'toSnakeCase'

  # Public: Converts all the prototype properties to camelCase.
  @camelize: -> @convert 'toCamelCase'

  # Public: Adds the specified alternatives of each properties on the
  # current prototype. The passed-in argument is the name of the class
  # method to call to convert the key string.
  #
  # alternateCase - The {String} name of the class method to use
  #                 to convert.
  @convert: (alternateCase) ->
    for key,value of @prototype
      alternate = @[alternateCase] key

      descriptor = Object.getPropertyDescriptor @prototype, key

      if descriptor?
        Object.defineProperty @prototype, alternate, descriptor
      else
        @prototype[alternate] = value

  # Public: Converts a string to `snake_case`.
  #
  # str - The {String} to convert.
  #
  # Returns a {String} in `snake_case` .
  @toSnakeCase: (str) ->
    str.
    replace(/([a-z])([A-Z])/g, "$1_$2")
    .split(/_+/g)
    .join('_')
    .toLowerCase()

  # Public: Converts a string to `camelCase`.
  #
  # str - The {String} to convert.
  #
  # Returns a {String} in `camelCase`.
  @toCamelCase: (str) ->
    a = str.toLowerCase().split(/[_\s-]/)
    s = a.shift()
    s = "#{ s }#{w.replace /^./, (s) -> s.toUpperCase()}" for w in a
    s


# Internal: Contains all the function that will instanciate a class
# with a specific number of arguments. These functions are all generated
# at runtime with the `Function` constructor.
BUILDS = (
  new Function( "return new arguments[0](#{
    ("arguments[1][#{ j-1 }]" for j in [ 0..i ] when j isnt 0).join ","
  });") for i in [ 0..24 ]
)

build = (klass, args) ->
  f = BUILDS[ if args? then args.length else 0 ]
  f klass, args

# Public: A `Cloneable` object can return a copy of itself through its `clone`
# method.
#
# The `Cloneable` generator function produces a different mixin when called
# with or without arguments.
#
# When called without argument, the returned mixin creates a clone using
# a copy constructor (a constructor that initialize the current object
# with an object).
#
#     class Dummy
#       @include mixins.Cloneable()
#
#       constructor: (options={}) ->
#         @property = options.property or 'foo'
#         @otherProperty = options.otherProperty or 'bar'
#
#     instance = new Dummy
#     otherInstance = instance.clone()
#     # otherInstance = {property: 'foo', otherProperty: 'bar'}
#
# When called with arguments, the `clone` method will call the class
# constructor with the values extracted from the given properties.
#
#     class Dummy
#       @include mixins.Cloneable('property', 'otherProperty')
#
#       constructor: (@property='foo', @otherProperty='bar') ->
#
#     instance = new Dummy
#     otherInstance = instance.clone()
#     # otherInstance = {property: 'foo', otherProperty: 'bar'}
#
# properties - A list of {String} of the properties to pass in the constructor.
#
# Returns a {ConcreteCloneable} mixin configured with the passed-in arguments.
mixins.Cloneable = (properties...) ->

  # Public: The concrete cloneable mixin as created by the
  # [Cloneable](../files/mixins/cloneable.coffee.html) generator.
  class ConcreteCloneable
    if properties.length is 0
      @included: (klass) -> klass::clone = -> new klass this
    else
      @included: (klass) -> klass::clone = -> build klass, properties.map (p) => @[ p ]


# Public: The `Delegation` mixin allow to define properties on an object that
# proxy another property of an object stored in one of its property.
#
# ```coffeescript
# class Dummy
#   @extend Delegation
#
#   @delegate 'someProperty', to: 'someObject'
#
#   constructor: ->
#     @someObject = someProperty: 'some value'
#
# instance = new Dummy
# instance.someProperty
# # 'some value'
# ```
class mixins.Delegation

  # Public: The `delegate` class method generates a property on the current
  # prototype that proxy the property of the given object.
  #
  # The `to` option specify the property of the object accessed by
  # the delegated property.
  #
  # The delegated property name can be prefixed with the name of the
  # accessed property
  #
  # ```coffeescript
  # class Dummy
  #   @extend Delegation
  #
  #   @delegate 'someProperty', to: 'someObject', prefix: true
  #   # delegated property is named `someObjectSomeProperty`
  # ```
  #
  # By default, using a prefix generates a camelCase property name.
  # You can use the `case` option to change that to a snake_case property
  # name.
  #
  # ```coffeescript
  # class Dummy
  #   @extend Delegation
  #
  #   @delegate 'some_property', to: 'some_object', prefix: true
  #   # delegated property is named `some_object_some_property`
  # ```
  #
  # The `delegate` method accept any number of properties to delegate
  # with the same options.
  #
  # ```coffeescript
  # class Dummy
  #   @extend Delegation
  #
  #   @delegate 'someProperty', 'someOtherProperty', to: 'someObject'
  # ```
  #
  # properties - A list of {String} of the properties to delegate.
  # options - The delegation options {Object}:
  #           :to - The {String} name of the target property.
  #           :prefix - A {Boolean} indicating whether to prefix the created
  #                     delegated property name with the target property name.
  #           :case - An optional {String} to define the case to use to generate
  #                   a prefixed delegated property.
  @delegate: (properties..., options={}) ->
    delegated = options.to
    prefixed = options.prefix
    _case = options.case or mixins.CAMEL_CASE

    properties.forEach (property) =>
      localAlias = property

      # Currently, only `camel`, and `snake` cases are supported.
      if prefixed
        switch _case
          when mixins.SNAKE_CASE
            localAlias = delegated + '_' + property
          when mixins.CAMEL_CASE
            localAlias = delegated + property.replace /^./, (m) ->
              m.toUpperCase()

      # The `Delegation` mixin rely on `Object.property` and thus can't
      # be used on IE8.
      Object.defineProperty @prototype, localAlias, {
        enumerable: true
        configurable: true
        get: -> @[ delegated ][ property ]
        set: (value) -> @[ delegated ][ property ] = value
      }


# Public: An `Equatable` object can be compared in equality with another object.
# Objects are considered as equal if all the listed properties are equal.
#
# ```coffeescript
# class Dummy
#   @include mixins.Equatable('p1', 'p2')
#
#   constructor: (@p1, @p2) ->
#     # ...
#
# dummy = new Dummy(10, 'foo')
# dummy.equals p1: 10, p2: 'foo'   # true
# dummy.equals new Dummy(5, 'bar') # false
# ```
#
# The `Equatable` mixin is called a parameterized mixin as
# it's in fact a function that will generate a mixin based
# on its arguments.
#
# properties - A list of {String} of the properties to compare to set equality.
#
# Returns a {ConcreteEquatable} mixin.
mixins.Equatable = (properties...) ->

  # Public: A concrete mixin is generated and returned by the
  # [Equatable](../files/mixins/equatable.coffee.html) generator.
  class ConcreteEquatable

    # Public: Compares the `properties` of the passed-in object with the current
    # object and return `true` if all the values are equal.
    #
    # o - The {Object} to compare to this instance.
    #
    # Returns a {Boolean} of whether the objects are equal or not.
    equals: (o) -> o? and properties.every (p) =>
      if @[ p ].equals? then @[ p ].equals o[ p ] else o[p] is @[ p ]

# Public: A `Formattable` object provides a `toString` that return
# a string representation of the current instance.
#
# ```coffeescript
# class Dummy
#   @include mixins.Formattable('Dummy', 'p1', 'p2')
#
#   constructor: (@p1, @p2) ->
#     # ...
#
# dummy = new Dummy(10, 'foo')
# dummy.toString()
# # [Dummy(p1=10, p2=foo)]
# ```
#
# You may wonder why the class name is passed in the `Formattable`
# call, the reason is that javascript minification can alter the
# naming of the functions and in that case, the constructor function
# name can't be relied on anymore.
# Passing the class name will ensure that the initial class name
# is always accessible through an instance.
#
# classname - The {String} name of the class for which generate a mixin.
# properties - A list of {String} of the properties to include
#              in the formatted output.
#
# Returns a {ConcreteFormattable} mixin.
mixins.Formattable = (classname, properties...) ->
  # Public: The concrete class as returned by the
  # [Formattable](../files/mixins/formattable.coffee.html) generator.
  class ConcreteFormattable
    if properties.length is 0
      ConcreteFormattable::toString = ->
        "[#{ classname }]"
    else
      ConcreteFormattable::toString = ->
        formattedProperties = ("#{ p }=#{ @[ p ] }" for p in properties)
        "[#{ classname }(#{ formattedProperties.join ', ' })]"

    # Public: Returns the class name {String} of this instance.
    classname: -> classname


# Internal: The list of properties that are unglobalizable by default.
DEFAULT_UNGLOBALIZABLE = [
  'globalizable'
  'unglobalizable'
  'globalized'
  'globalize'
  'unglobalize'
  'globalizeMember'
  'unglobalizeMember'
  'keepContext'
  'previousValues'
  'previousDescriptors'
]

# Public: A `Globalizable` object can expose some methods on the
# specified global object (`window` in a browser or `global` in nodejs
# when using methods from the `vm` module).
#
# The *globalization* process is **reversible** and take care to preserve
# the initial properties of the global that may be overriden.
#
# The properties exposed on the global object are defined
# in the `globalizable` property.
#
# ```coffeescript
# class Dummy
#   @include mixins.Globalizable window
#
#   globalizable: ['someMethod']
#
#   someMethod: -> console.log 'in some method'
#
# instance = new Dummy
# instance.globalize()
#
# someMethod()
# # output: 'in some method'
# ```
#
# The process can be reversed with the `unglobalize` method.
#
# ```coffeescript
# instance.unglobalize()
# ```
#
# The `Globalizable` function takes the target global object as the first
# argument. The second argument define whether the functions on
# a globalized object are bound to this object or to the global object.
#
# global - The global {Object} onto which adds globalized methods
#          and properties.
# keepContext - A {Boolean} defining whether the initial context
#               of the methods are preserved or not.
#
# Returns a {ConcreteGlobalizable} mixin to decorate a class with.
mixins.Globalizable = (global, keepContext=true) ->

  # Public: The concrete globalizable mixin as returned by the
  # [Globalizable](../files/mixins/globalizable.coffee.html) generator.
  class ConcreteGlobalizable

    # Public: An {Array} storing the {String} name of the properties that
    # can't be globalized. This takes precedence over the `globalizable`
    # property of the decorated class.
    @unglobalizable: DEFAULT_UNGLOBALIZABLE.concat()

    # Public: {Boolean} that defines whether the methods context
    # are preserved or not.
    keepContext: keepContext

    # Public: The method that actually exposes the object methods on global.
    globalize: ->
      # But only if the object isn't already `globalized`.
      return if @globalized

      # Creates the objects that will stores the previous values
      # and property descriptors present on `global` before the
      # object globalization.
      @previousValues = {}
      @previousDescriptors = {}

      # Then for each properties set for globalization the
      # `globalizeMember` method is called.
      @globalizable.forEach (k) =>
        unless k in (@constructor.unglobalizable or ConcreteGlobalizable.unglobalizable)
          @globalizeMember k

      # And the object is marked as `globalized`.
      @globalized = true

    # Public: The reverse process of `globalize`.
    unglobalize: ->
      return unless @globalized

      # For each properties set for globalization the
      # `unglobalizeMember` method is called.
      @globalizable.forEach (k) =>
        unless k in (@constructor.unglobalizable or ConcreteGlobalizable.unglobalizable)
          @unglobalizeMember k

      # And then the object is cleaned of the globalization artifacts
      # and the `globalized` mark is removed.
      @previousValues = null
      @previousDescriptors = null
      @globalized = false

    # Internal: Exposes a member of the current object on global.
    #
    # key - The {String} name of the property to globalize.
    globalizeMember: (key) ->
      # If possible we prefer using property descriptors rather than
      # accessing directly the properties. It will allow to correctly
      # expose virtual properties (get/set) created through
      # `Object.defineProperty`.
      oldDescriptor = Object.getPropertyDescriptor global, key
      selfDescriptor = Object.getPropertyDescriptor this, key

      # If we have a property descriptor for the previous global property
      # we store it to restore it in the `unglobalize` process.
      if oldDescriptor?
        @previousDescriptors[ key ] = oldDescriptor
      # Otherwise the property value is stored.
      else if @[ key ]?
        @previousValues[ key ] = global if global[ key ]?

      # If we have a property descriptor for the object property, we'll
      # use it to create the property on global with the same settings.
      if selfDescriptor?
        # But if we have to bind functions to the object there'll be
        # a need for additional setup.
        if keepContext
          # For instance, if the descriptor contains a `get` and `set`
          # property then we have to bind both.
          if selfDescriptor.get? or selfDescriptor.set?
            selfDescriptor.get = selfDescriptor.get?.bind(@)
            selfDescriptor.set = selfDescriptor.set?.bind(@)
          # Otherwise, if the value is a function we bind it.
          else if typeof selfDescriptor.value is 'function'
            selfDescriptor.value = selfDescriptor.value.bind(@)

        # Finally the descriptor is used to create the new property
        # on the global object.
        Object.defineProperty global, key, selfDescriptor

      # Without a property descriptor for the object's property
      # the value is retreived and used to create a new property
      # descriptor.
      else
        value = @[ key ]
        value = value.bind(@) if typeof value is 'function' and keepContext
        Object.defineProperty global, key, {
          value
          enumerable: true
          writable: true
          configurable: true
        }

    # Internal: The inverse process of `globalizeMember`.
    #
    # key - The {String} name of the property to unglobalize.
    unglobalizeMember: (key) ->
      # If we have a previous descriptor we restore ot on global.
      if @previousDescriptors[ key ]?
        Object.defineProperty global, key, @previousDescriptors[ key ]

      # If there's no previous descriptor but a previous value,
      # the value is affected to the global property.
      else if @previousValues[ key ]?
        global[ key ] = @previousValues[ key ]

      # And if there's nothing the property is unset.
      else
        global[ key ] = undefined


# Public: The `HasAncestors` mixin adds several methods to instance to deal
# with parents and ancestors.
#
# ```coffee
# class Dummy
#   @concern mixins.HasAncestors through: 'parentNode'
# ```
#
# The `through` option allow to specify the property name that access
# to the parent.
#
# options - The option {Object}:
#           :through - The {String} name of the property giving access
#           to the instance parent.
#
# Returns a {ConcreteHasAncestors} mixin.
mixins.HasAncestors = (options={}) ->
  through = options.through or 'parent'

  # Public: The concrete mixin as returned by the
  # [HasAncestors](../files/mixins/has_ancestors.coffee.html) generator.
  class ConcreteHasAncestors

    # Public: Returns an array of all the ancestors of the current object.
    # The ancestors are ordered such as the first element is the direct
    # parent of the current object.
    @getter 'ancestors', ->
      ancestors = []
      parent = @[ through ]

      while parent?
        ancestors.push parent
        parent = parent[ through ]

      ancestors

    # Public: Returns an object containing the current object followed by its
    # parent and ancestors.
    @getter 'selfAndAncestors', -> [ this ].concat @ancestors

    # Public: Defines a getter property on instances named with `name` and that
    # filter the `ancestors` array with the given `block`.
    @ancestorsScope: (name, block) ->
      @getter name, -> @ancestors.filter(block, this)


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


# Public: A `Memoizable` object can store data resulting of heavy methods
# in order to speed up further call to that method.
#
# The invalidation of the memoized data is defined using a `memoizationKey`.
# That key should be generated based on the data that may induce changes
# in the functions's results.
#
# ```coffeescript
# class Dummy
#   @include mixins.Memoizable
#
#   constructor: (@p1, @p2) ->
#     # ...
#
#   heavyMethod: (arg) ->
#     key = "heavyMethod-#{arg}"
#     return @memoFor key if @memoized key
#
#     # do costly computation
#     @memoize key, result
#
#   memoizationKey: -> "#{p1};#{p2}"
# ```
class mixins.Memoizable
  # Public: Returns `true` if data are available for the given `prop`.
  #
  # When the current state of the object don't match the stored
  # memoization key, the whole data stored in the memo are cleared.
  #
  # prop - The {String} name of a property.
  #
  # Retuns a {Boolean} of whether the value of the propery is memoized or not.
  memoized: (prop) ->
    if @memoizationKey() is @__memoizationKey__
      @__memo__?[ prop ]?
    else
      @__memo__ = {}
      false

  # Public: Returns the memoized data for the given `prop`.
  #
  # prop - The {String} name of a property.
  #
  # Returns the memoized data for the given prop
  memoFor: (prop) -> @__memo__[ prop ]

  # Public: Register a memo in the current object for the given `prop`.
  # The memoization key is updated with the current state of the
  # object.
  memoize: (prop, value) ->
    @__memo__ ||= {}
    @__memoizationKey__ = @memoizationKey()
    @__memo__[ prop ] = value

  # Public: Abstract: Generates the memoization key for this instance's state.
  #
  # By default the memoization key of an object is the return of its `toString`
  # method. **You SHOULD redefine the memoization key generation in the class
  # including the `Memoizable` mixin.**
  #
  # Returns a {String} that identify the state of the current instance.
  memoizationKey: -> @toString()


#
mixins.Parameterizable = (method, parameters, allowPartial=false) ->
  #
  class ConcreteParameterizable

    ##### Parameterizable.included
    #
    @included: (klass) ->
      f = (args..., strict)->
        (args.push(strict); strict = false) if typeof strict is 'number'
        output = {}

        o = arguments[ 0 ]
        n = 0
        firstArgumentIsObject = o? and typeof o is 'object'

        for k,v of parameters
          value = if firstArgumentIsObject then o[ k ] else arguments[ n++ ]
          output[ k ] = parseFloat value

          if isNaN output[ k ]
            if strict
              keys = (k for k in parameters).join ', '
              throw new Error "#{ output } doesn't match pattern {#{ keys }}"
            if allowPartial then delete output[ k ] else output[ k ] = v

        output

      klass[method] = f
      klass::[method] = f


# Public: A `Poolable` class has the ability to manage a pool of instances
# and prevent the further creation of instances as long as unused ones
# are still present.
class mixins.Poolable

  # Internal: The two objects stores are created in the extended hook to avoid
  # that all the class extending `Poolable` shares the same instances.
  @extended: (klass) ->
    klass.usedInstances = []
    klass.unusedInstances = []

  # Public: The `get` method returns an instance of the class.
  # If the class defines an `init` method, it will be called with the
  # passed-in `options` {Object}.
  #
  # options - The option {Object} to use to setup the created instance.
  #
  # Returns an instance of the current class.
  @get: (options={}) ->
    # Either retrieve or create the instance.
    if @unusedInstances.length > 0
      instance = @unusedInstances.shift()
    else
      instance = new this

    # Stores the instance in the used pool.
    @usedInstances.push instance

    # Init the instance and return it.
    instance.init(options)
    instance

  # Public: The `release` method takes an instance and move
  # it from the the used pool to the unused pool.
  #
  # instance - The instance of the current class.
  @release: (instance) ->
    # We can't release unused instances created using
    # the `new` operator without using `get`.
    unless instance in @usedInstances
      throw new Error "Can't release an unused instance"

    # The instance is removed from the used instances pool.
    index = @usedInstances.indexOf(instance)
    @usedInstances.splice(index, 1)

    # And then moved to the unused instances one.
    @unusedInstances.push instance

  # Public: Default `init` implementation, just copy all the options
  # in the instance.
  #
  # options - The setup {Object} for this instance.
  init: (options={}) -> @[ k ] = v for k,v of options

  # Public: Default `dispose` implementation, call the `release` method
  # on the instance constructor. A proper implementation should
  # take care of removing/cleaning all the instance properties.
  dispose: -> @constructor.release(this)


# Public: A `Sourcable` object is an object that can return the source code
# to re-create it by code.
#
# ```coffeescript
# class Dummy
#   @include mixins.Sourcable('geomjs.Dummy', 'p1', 'p2')
#
#   constructor: (@p1, @p2) ->
#
# dummy = new Dummy(10,'foo')
# dummy.toSource() # "new geomjs.Dummy(10,'foo')"
# ```
#
# name - The {String} path to the current class.
# signature - A list of {String} name of properties
mixins.Sourcable = (name, signature...) ->

  # Public: A concrete class is generated and returned by
  # [Sourcable](../files/mixins/sourcable.coffee.html).
  class ConcreteSourcable

    # Internal: Generates the source for a property's value.
    sourceFor = (value) ->
      switch typeof value
        when 'object'
          isArray = Object::toString.call(value).indexOf('Array') isnt -1
          if isArray
            "[#{ value.map (el) -> sourceFor el }]"
          else
            if value.toSource?
              value.toSource()
            else
              value
        when 'string'
          "'#{ value.replace "'", "\\'" }'"
        else value

    # Public: Returns the source code corresponding to the current instance.
    #
    # Returns a {String} with the source of the instance.
    toSource: ->
      args = (@[ arg ] for arg in signature).map (o) -> sourceFor o

      "new #{ name }(#{ args.join ',' })"

mixins.Sourcable._name = 'Sourcable'
