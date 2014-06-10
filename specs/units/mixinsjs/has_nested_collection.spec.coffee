describe 'mixins.HasNestedCollection', ->
  beforeEach ->
    @testClass = class TestClass
      @concern mixins.HasCollection 'children', 'child'
      @concern mixins.HasNestedCollection 'descendants', through: 'children'

      constructor: (@name, @children=[]) ->

    @instanceRoot =  new @testClass 'root'
    @instanceA =  new @testClass 'a'
    @instanceB =  new @testClass 'b'
    @instanceC =  new @testClass 'c'

    @instanceRoot.addChild @instanceA
    @instanceRoot.addChild @instanceB

    @instanceA.addChild @instanceC

  it 'returns all its descendants in a single array', ->
    expect(@instanceRoot.descendants).toEqual([
      @instanceA
      @instanceC
      @instanceB
    ])

  describe 'using the descendantsScope method', ->
    beforeEach ->
      @testClass.descendantsScope 'descendantsNamedB', (item) ->
        item.name is 'b'

    it 'creates a method returning a filtered array of descendants', ->
      expect(@instanceRoot.descendantsNamedB).toEqual([ @instanceB ])
