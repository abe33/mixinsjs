isCommonJS = typeof module isnt "undefined"

if isCommonJS
  exports = module.exports or {}
else
  exports = window.mixins = {}

mixins = exports

mixins.version = '0.1.2'

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


Function::include = (mixins...) ->
  excluded = ['constructor', 'excluded']
  @__mixins__ ||= []

  @__super__ ||= {}
  @__super__ = Object.create @__super__

  for mixin in mixins
    @__mixins__.push mixin

    excl = excluded.concat()
    excl = excl.concat mixin::excluded if mixin::excluded?

    for k, v of mixin.prototype
      if k not in excl
        if @::[k]?
          v.__super__ ||= []
          v.__super__.push @::[k]

          v.__included__ ||= []
          v.__included__.push @

        @__super__[k] = v
        @::[k] = v

    mixin.included? this

  unless @::super?
    @::super = (args...) ->
      caller = arguments.caller or @super.caller
      if caller?

        if caller.__super__?
          value = caller.__super__[caller.__included__.indexOf @constructor]
          if value?
            value.apply(this, args)
          else
            throw new Error "No super method for #{caller}"
        else
          key = k for k,v of @constructor.prototype when v is caller
          if key?
            value = @constructor.__super__[key].apply(this, args)
          else
            throw new Error "No super method for #{caller}"
      else
        throw new Error "Super called with a caller"

  this

Function::extend = (mixins...) ->
  excluded = ['extended', 'excluded', 'included']
  for mixin in mixins
    excl = excluded.concat()
    excl = excl.concat mixin.excluded if mixin.excluded?
    @[k] = v for k,v of mixin when k not in excl
    mixin.extended? this

  this

Function::concern = (mixins...) ->
  @include.apply(this, mixins)
  @extend.apply(this, mixins)

# @toc

## Cloneable

#### Build

# Contains all the function that will instanciate a class with a specific
# number of arguments. These functions are all generated at runtime with
# the `Function` constructor.
BUILDS = (
  new Function( "return new arguments[0](#{
    ("arguments[1][#{j-1}]" for j in [0..i] when j isnt 0 ).join ","
  });") for i in [0..24]
)

build = (klass, args) ->
  f = BUILDS[if args? then args.length else 0]
  f klass, args

#### Cloneable

# A `Cloneable` object can return a copy of itself through the `clone`
# method. The `Cloneable` function product a different mixin when called
# with or without arguments.
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
mixins.Cloneable = (properties...) ->
  class ConcreteCloneable
    if properties.length is 0
      @included: (klass) -> klass::clone = -> new klass this
    else
      @included: (klass) -> klass::clone = -> build klass, properties.map (p) => @[p]

mixins.Cloneable._name = 'Cloneable'

# @toc
## Equatable

# An `Equatable` object can be compared in equality with another object.
# Objects are considered as equals if all the listed properties are equal.
#
#     class Dummy
#       @include mixins.Equatable('p1', 'p2')
#
#       constructor: (@p1, @p2) ->
#         # ...
#
#     dummy = new Dummy(10, 'foo')
#     dummy.equals p1: 10, p2: 'foo'   # true
#     dummy.equals new Dummy(5, 'bar') # false
#
# The `Equatable` mixin is called a parameterized mixin as
# it's in fact a function that will generate a mixin based
# on its arguments.
mixins.Equatable = (properties...) ->

  # A concrete class is generated and returned by `Equatable`.
  # This class extends `Mixin` and can be attached as any other
  # mixin with the `attachTo` method.
  class ConcreteEquatable
    ##### Equatable::equals
    #
    # Compares the `properties` of the passed-in object with the current
    # object and return `true` if all the values are equal.
    equals: (o) -> o? and properties.every (p) =>
      if @[p].equals? then @[p].equals o[p] else o[p] is @[p]

mixins.Equatable._name = 'Equatable'

# @toc
## Formattable

# A `Formattable` object provides a `toString` that return
# a string representation of the current instance.
#
#     class Dummy
#       Formattable('Dummy', 'p1', 'p2').attachTo Dummy
#
#       constructor: (@p1, @p2) ->
#         # ...
#
#     dummy = new Dummy(10, 'foo')
#     dummy.toString()
#     # [Dummy(p1=10, p2=foo)]
#
# You may wonder why the class name is passed in the `Formattable`
# call, the reason is that javascript minification can alter the
# naming of the functions and in that case, the constructor function
# name can't be relied on anymore.
# Passing the class name will ensure that the initial class name
# is always accessible through an instance.
mixins.Formattable = (classname, properties...) ->
  #
  class ConcretFormattable
    ##### Formattable::toString
    #
    # Returns the string reprensentation of this instance.
    if properties.length is 0
      ConcretFormattable::toString = ->
        "[#{classname}]"
    else
      ConcretFormattable::toString = ->
        formattedProperties = ("#{p}=#{@[p]}" for p in properties)
        "[#{classname}(#{formattedProperties.join ', '})]"

    ##### Formattable::classname
    #
    # Returns the class name of this instance.
    classname: -> classname

mixins.Formattable._name = 'Formattable'

# @toc

## Memoizable

# A `Memoizable` object can store data resulting of heavy methods
# in order to speed up further call to that method.
#
# The invalidation of the memoized data is defined using a `memoizationKey`.
# That key should be generated based on the data that may induce changes
# in the functions's results.
#
#     class Dummy
#       Memoizable.attachTo Dummy
#
#       constructor: (@p1, @p2) ->
#         # ...
#
#       heavyMethod: (arg) ->
#         key = "heavyMethod-#{arg}"
#         return @memoFor key if @memoized key
#
#         # do costly computation
#         @memoize key, result
#
#       memoizationKey: -> "#{p1};#{p2}"
class mixins.Memoizable
  ##### Memoizable::memoized
  #
  # Returns `true` if data are available for the given `prop`.
  #
  # When the current state of the object don't match the stored
  # memoization key, the whole data stored in the memo are cleared.
  memoized: (prop) ->
    if @memoizationKey() is @__memoizationKey__
      @__memo__?[prop]?
    else
      @__memo__ = {}
      false

  ##### Memoizable::memoFor
  #
  # Returns the memoized data for the given `prop`.
  memoFor: (prop) -> @__memo__[prop]

  ##### Memoizable::memoize
  #
  # Register a memo in the current object for the given `prop`.
  # The memoization key is updated with the current state of the
  # object.
  memoize: (prop, value) ->
    @__memo__ ||= {}
    @__memoizationKey__ = @memoizationKey()
    @__memo__[prop] = value

  ##### Memoizable::memoizationKey
  #
  # **Virtual Method**
  #
  # Generates the memoization key for this instance's state.
  memoizationKey: -> @toString()


# @toc

## Parameterizable

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

        o = arguments[0]
        n = 0
        firstArgumentIsObject = o? and typeof o is 'object'

        for k,v of parameters
          value = if firstArgumentIsObject then o[k] else arguments[n++]
          output[k] = parseFloat value

          if isNaN output[k]
            if strict
              keys = (k for k in parameters).join ', '
              throw new Error "#{output} doesn't match pattern {#{keys}}"
            if allowPartial then delete output[k] else output[k] = v

        output

      klass[method] = f
      klass::[method] = f

mixins.Parameterizable._name = 'Parameterizable'

# @toc

## Poolable

#
class mixins.Poolable

  #### Poolable.extended

  # The two objects stores are created in the extended hook to avoid
  # that all the class extending `Poolable` shares the same instances.
  @extended: (klass) ->
    klass.usedInstances = []
    klass.unusedInstances = []

  #### Poolable.get

  # The `get` method returns an instance of the class.
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

  #### Poolable.release

  # The `release` method takes an instance and move it from the
  # the used pool to the unused pool.
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

  #### Poolable::init

  # Default `init` implementation, just copy all the options
  # in the instance.
  init: (options={}) -> @[k] = v for k,v of options

  #### Poolable::dispose

  # Default `dispose` implementation, call the `release` method
  # on the instance constructor. A proper implementation should
  # take care of removing/cleaning all the instance properties.
  dispose: -> @constructor.release(this)

# @toc

## Sourcable

# A `Sourcable` object is an object that can return the source code
# to re-create it by code.
#
#     class Dummy
#       Sourcable('geomjs.Dummy', 'p1', 'p2').attachTo Dummy
#
#       constructor: (@p1, @p2) ->
#
#     dummy = new Dummy(10,'foo')
#     dummy.toSource() # "new geomjs.Dummy(10,'foo')"
mixins.Sourcable = (name, signature...) ->

  # A concrete class is generated and returned by `Sourcable`.
  # This class extends `Mixin` and can be attached as any other
  # mixin with the `attachTo` method.
  class ConcreteSourcable
    #
    sourceFor = (value) ->
      switch typeof value
        when 'object'
          isArray = Object::toString.call(value).indexOf('Array') isnt -1
          if value.toSource?
            value.toSource()
          else
            if isArray
              "[#{value.map (el) -> sourceFor el}]"
            else
              value
        when 'string'
          if value.toSource?
            value.toSource()
          else
            "'#{value.replace "'", "\\'"}'"
        else value

    ##### Sourcable::toSource
    #
    # Return the source code corresponding to the current instance.
    toSource: ->
      args = (@[arg] for arg in signature).map (o) -> sourceFor o

      "new #{name}(#{args.join ','})"

mixins.Sourcable._name = 'Sourcable'
