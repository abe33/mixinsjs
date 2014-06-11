
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
