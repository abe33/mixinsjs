xdescribe mixins.Globalizable, ->
  given 'testClass', ->
    class TestClass
      @include mixins.Globalizable spectacular.global

      globalizable: [ 'method' ]

      property: 'foo'
      method: -> @property

  given 'instance', -> new @testClass

  context 'when globalized', ->
    before -> @instance.globalize()
    after -> @instance.unglobalize()

    specify 'the globalized method', ->
      expect(method()).to equal 'foo'

    whenPass ->
      context 'and then unglobalized', ->

        before -> @instance.unglobalize()

        specify 'the unglobalized method', ->
          expect(typeof method).to equal 'undefined'
