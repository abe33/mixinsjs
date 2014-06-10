describe 'mixins.Formattable', ->
  describe 'when called with extra arguments', ->
    beforeEach ->
      class TestClass
        @include mixins.Formattable('TestClass', 'a','b')

        constructor: (@a, @b) ->

      @instance = new TestClass 5, 'foo'

    it 'returns a formatted string with extra details', ->
      expect(@instance.toString()).toEqual('[TestClass(a=5, b=foo)]')

  describe 'when called without extra arguments', ->
    beforeEach ->
      class TestClass
        @include mixins.Formattable('TestClass')

      @instance = new TestClass

    it 'returns a formatted string without any details', ->
      expect(@instance.toString()).toEqual('[TestClass]')
