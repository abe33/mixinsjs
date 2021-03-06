
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
