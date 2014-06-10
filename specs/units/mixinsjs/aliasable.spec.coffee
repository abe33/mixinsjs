describe 'mixins.Aliasable', ->
  beforeEach ->
    class TestClass
      @extend mixins.Aliasable

      foo: -> 'foo'
      @getter 'bar', -> 'bar'

      @alias 'foo', 'oof', 'ofo'
      @alias 'bar', 'rab', 'bra'

    @instance = new TestClass

  it 'creates aliases for object properties', ->
    expect(@instance.oof).toEqual(@instance.foo)
    expect(@instance.ofo).toEqual(@instance.foo)
    expect(@instance.rab).toEqual(@instance.bar)
    expect(@instance.bra).toEqual(@instance.bar)
