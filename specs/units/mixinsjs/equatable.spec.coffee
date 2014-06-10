
describe 'mixins.Equatable', ->
  describe 'when called with a list of properties name', ->
    beforeEach ->
      class TestClass
        @include mixins.Equatable('a','b')
        constructor: (@a, @b) ->

      @instance1 = new TestClass 1, 2
      @instance2 = new TestClass 1, 2
      @instance3 = new TestClass 2, 2

    it 'returns true with two similar instancew', ->
      expect(@instance1.equals(@instance2)).toBeTruthy()

    it 'returns false with tow different instances', ->
      expect(@instance1.equals(@instance3)).toBeFalsy()
