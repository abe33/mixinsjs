
describe 'mixins.Cloneable', ->
  describe 'when called without arguments', ->
    beforeEach ->
      class TestClass
        @include mixins.Cloneable()

        constructor: (@self) ->

      @instance = new TestClass

    it 'creates a copy by passing the reference in the copy constructor', ->
      clone = @instance.clone()

      expect(clone).toBeDefined()
      expect(clone.self).toBe(@instance)

  describe 'when called with arguments', ->
    beforeEach ->
      class TestClass
        @include mixins.Cloneable('a', 'b')

        constructor: (@a, @b) ->

      @instance = new TestClass 10, 'foo'

    it 'creates a copy of the object', ->
      clone = @instance.clone()

      expect(clone).toBeDefined()
      expect(clone).toEqual(@instance)
      expect(clone).not.toBe(@instance)
