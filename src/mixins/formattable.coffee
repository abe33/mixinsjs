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
# Returns a {ConcretFormattable} mixin.
mixins.Formattable = (classname, properties...) ->
  # Public: The concrete class as returned by the
  # [Formattable](../files/mixins/formattable.coffee.html) generator.
  class ConcretFormattable
    if properties.length is 0
      ConcretFormattable::toString = ->
        "[#{ classname }]"
    else
      ConcretFormattable::toString = ->
        formattedProperties = ("#{ p }=#{ @[ p ] }" for p in properties)
        "[#{ classname }(#{ formattedProperties.join ', ' })]"

    # Public: Returns the class name {String} of this instance.
    classname: -> classname

mixins.Formattable._name = 'Formattable'
