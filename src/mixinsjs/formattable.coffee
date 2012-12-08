# @toc
Mixin = require './mixin'

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
Formattable = (classname, properties...) ->
  #
  class ConcretFormattable extends Mixin
    ##### Formattable.attachTo
    #
    # See [Mixin.attachTo](src_geomjs_mixins_mixin.html#mixinattachto)

    ##### Formattable::toString
    #
    # Returns the string reprensentation of this instance.
    toString: ->
      if properties.length is 0
        "[#{classname}]"
      else
        formattedProperties = ("#{p}=#{@[p]}" for p in properties)
        "[#{classname}(#{formattedProperties.join ', '})]"

    ##### Formattable::classname
    #
    # Returns the class name of this instance.
    classname: -> classname

module.exports = Formattable
