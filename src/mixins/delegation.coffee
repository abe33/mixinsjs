
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
