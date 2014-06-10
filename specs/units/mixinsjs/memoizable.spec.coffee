xdescribe mixins.Memoizable, ->
  given 'testClass', ->
    class TestClass
      @include mixins.Memoizable

      constructor: (@a=10, @b=20) ->

      getObject: ->
        return @memoFor 'getObject' if @memoized 'getObject'

        object = {@a, @b, c: @a + @b}

        @memoize 'getObject', object

      memoizationKey: -> "#{@a};#{@b}"

  subject 'instance', -> new @testClass

  given 'initial', -> @instance.getObject()
  given 'secondCall', -> @instance.getObject()

  specify 'the second object', -> @secondCall.should be @initial

  context 'when changing a property of the objet', ->
    before ->
      @initial

      @instance.a = 20

    given 'secondCall', -> @instance.getObject()

    specify 'the second object', -> @secondCall.shouldnt equal @initial
