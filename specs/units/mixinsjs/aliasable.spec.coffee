describe mixins.Aliasable, ->

  given 'testClass', ->
    class TestClass
      @extend mixins.Aliasable

      foo: -> 'foo'
      @getter 'bar', -> 'bar'

      @alias 'foo', 'oof', 'ofo'
      @alias 'bar', 'rab', 'bra'

  subject 'instance', -> new @testClass

  its 'oof', -> should equal @instance.foo
  its 'ofo', -> should equal @instance.foo

  its 'rab', -> should equal @instance.bar
  its 'bra', -> should equal @instance.bar
