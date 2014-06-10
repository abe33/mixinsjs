describe 'mixins.Delegation', ->
  describe 'included in a class with delegated properties', ->
    beforeEach ->
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

      @instance = new TestClass

    describe 'when accessing a delegated property', ->
      it 'returns the composed instance value', ->
        expect(@instance.foo).toEqual('foo')
        expect(@instance.bar).toEqual('bar')

      describe 'that hold a function', ->
        describe 'calling the function', ->
          it 'binds the methods to the delegated object', ->
            expect(@instance.func()).toEqual('foo')

      describe 'with prefix', ->
        it 'returns the composed instance value', ->
          expect(@instance.subObjectBaz).toEqual('baz')

        describe 'and snake case', ->
          it 'returns the composed instance value', ->
            expect(@instance.subObject_baz).toEqual('baz')

    describe 'writing on a delegated property', ->

      beforeEach ->
        @instance.foo = 'oof'
        @instance.bar = 'rab'

      it 'writes in the composed instance properties', ->
        expect(@instance.foo).toEqual('oof')
        expect(@instance.bar).toEqual('rab')

      describe 'with prefix', ->
        beforeEach -> @instance.subObjectBaz = 'zab'

        it 'writes in the composed instance properties', ->
          expect(@instance.subObjectBaz).toEqual('zab')

        describe 'and snake case', ->

          beforeEach -> @instance.subObject_baz = 'zab'

          it 'writes in the composed instance properties', ->
            expect(@instance.subObject_baz).toEqual('zab')
