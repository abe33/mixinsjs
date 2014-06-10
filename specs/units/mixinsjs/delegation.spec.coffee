xdescribe mixins.Delegation, ->
  context 'on a class to delegate properties', ->
    given 'testClass', ->
      class TestClass
        @extend mixins.Delegation

        @delegate 'foo', 'bar', 'func', to: 'subObject'
        @delegate 'baz', to: 'subObject', prefix: true
        @delegate 'baz', to: 'subObject', prefix: true, case: 'snake'

        constructor: ->
          @subObject =
            foo: 'foo'
            bar: 'bar'
            baz: 'baz'
            func: -> @foo

    given 'instance', -> new @testClass

    context 'accessing a delegated property', ->

      specify -> expect(@instance.foo).to equal 'foo'
      specify -> expect(@instance.bar).to equal 'bar'

      context 'that hold a function', ->
        context 'calling the function', ->
          specify 'should be bound to the delegated object', ->
            expect(@instance.func()).to equal 'foo'

      context 'with prefix', ->
        specify -> expect(@instance.subObjectBaz).to equal 'baz'

        context 'and snake case', ->
          specify -> expect(@instance.subObject_baz).to equal 'baz'

    context 'writing on a delegated property', ->

      before ->
        @instance.foo = 'oof'
        @instance.bar = 'rab'

      specify -> expect(@instance.foo).to equal 'oof'
      specify -> expect(@instance.bar).to equal 'rab'

      context 'with prefix', ->
        before -> @instance.subObjectBaz = 'zab'

        specify -> expect(@instance.subObjectBaz).to equal 'zab'

        context 'and snake case', ->
          before -> @instance.subObject_baz = 'zab'

          specify -> expect(@instance.subObject_baz).to equal 'zab'
