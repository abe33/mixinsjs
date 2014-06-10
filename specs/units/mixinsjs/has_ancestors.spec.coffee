describe 'mixins.HasAncestors', ->
  beforeEach ->
    @testClass = class TestClass
      @concern mixins.HasAncestors through: 'customParent'

      constructor: (@name, @customParent) ->

      toString: -> 'instance ' + @name

    @instanceA = new TestClass 'a'
    @instanceB = new TestClass 'b', @instanceA
    @instanceC = new TestClass 'c', @instanceB

  describe '#ancestors', ->

    it 'returns an array of the object ancestors', ->
      expect(@instanceC.ancestors).toEqual([
        @instanceB
        @instanceA
      ])

  describe '#selfAndAncestors', ->
    it 'returns an array of the object and its ancestors', ->
      expect(@instanceC.selfAndAncestors).toEqual([
        @instanceC
        @instanceB
        @instanceA
      ])

  describe '.ancestorsScope', ->
    beforeEach ->
      @testClass.ancestorsScope 'isB', (p) -> p.name is 'b'

    it 'should creates a scope filtering the ancestors', ->
      expect(@instanceC.isB).toEqual([@instanceB])
