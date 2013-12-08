console.log mixins.HasNestedCollection

describe mixins.HasNestedCollection, ->
  given 'testClass', ->
    class TestClass
      @concern mixins.HasCollection 'children', 'child'
      @concern mixins.HasNestedCollection 'descendants', through: 'children'

      constructor: (@name, @children=[]) ->

  given 'instanceRoot', -> new @testClass 'root'
  given 'instanceA', -> new @testClass 'a'
  given 'instanceB', -> new @testClass 'b'
  given 'instanceC', -> new @testClass 'c'

  before ->
    @instanceRoot.addChild @instanceA
    @instanceRoot.addChild @instanceB

    @instanceA.addChild @instanceC

  subject -> @instanceRoot

  its 'descendants', -> should equal [@instanceA, @instanceC, @instanceB]

  context 'using the descendantsScope method', ->
    before ->
      @testClass.descendantsScope 'descendantsNamedB', (item) ->
        item.name is 'b'

    its 'descendantsNamedB', -> should equal [ @instanceB ]
