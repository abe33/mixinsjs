
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
