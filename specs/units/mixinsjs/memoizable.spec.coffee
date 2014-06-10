describe 'mixins.Memoizable', ->
  beforeEach ->
    @testClass = class TestClass
      @include mixins.Memoizable

      constructor: (@a=10, @b=20) ->

      getObject: ->
        return @memoFor 'getObject' if @memoized 'getObject'

        object = {@a, @b, c: @a + @b}

        @memoize 'getObject', object

      memoizationKey: -> "#{@a};#{@b}"

    @instance = new @testClass
    @initial = @instance.getObject()
    @secondCall = @instance.getObject()

  it 'stores the result of the first call and return it in the second', ->
    expect(@secondCall).toBe(@initial)

  describe 'when changing a property of the objet', ->
    beforeEach ->
      @instance.a = 20

    it 'clears the memoized value', ->
      expect(@instance.getObject()).not.toEqual(@initial)
