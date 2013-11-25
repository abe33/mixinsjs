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
