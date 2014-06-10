describe 'mixins.Globalizable', ->
  beforeEach ->
    class TestClass
      @include mixins.Globalizable global ? window

      globalizable: [ 'method' ]

      property: 'foo'
      method: -> @property

    @instance = new TestClass

  describe 'when globalized', ->
    beforeEach -> @instance.globalize()
    afterEach -> @instance.unglobalize()

    it 'creates methods on the global object', ->
      expect(method()).toEqual('foo')

    describe 'and then unglobalized', ->
      beforeEach -> @instance.unglobalize()

      it 'removes the methods from the global object', ->
        expect(typeof method).toEqual('undefined')
