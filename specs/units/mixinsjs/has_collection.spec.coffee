describe 'mixins.HasCollection', ->
  beforeEach ->
    @testClass = class TestClass
      @concern mixins.HasCollection 'customChildren', 'customChild'

      constructor: (@name, @customChildren=[]) ->

    @instanceRoot = new TestClass 'root'
    @instanceA = new TestClass 'a'
    @instanceB = new TestClass 'b'

    @instanceRoot.customChildren.push @instanceA
    @instanceRoot.customChildren.push @instanceB

  describe 'included in class TestClass', ->

    it 'provides properties to count children', ->
      expect(@instanceRoot.customChildrenSize).toEqual(2)
      expect(@instanceRoot.customChildrenLength).toEqual(2)
      expect(@instanceRoot.customChildrenCount).toEqual(2)

    describe 'using the generated customChildrenScope method', ->
      beforeEach ->
        @testClass.customChildrenScope 'childrenNamedB', (child) ->
          child.name is 'b'

      it 'creates a property returning a filtered array of children', ->
        expect(@instanceRoot.childrenNamedB).toEqual([ @instanceB ])

    describe 'adding a child using addCustomChild', ->

      beforeEach ->
        @instanceC = new @testClass 'c'
        @instanceRoot.addCustomChild @instanceC

      it 'updates the children count', ->
        expect(@instanceRoot.customChildrenSize).toEqual(3)

      describe 'a second time', ->
        beforeEach -> @instanceRoot.addCustomChild @instanceC

        it 'does not add the instance', ->
          expect(@instanceRoot.customChildrenSize).toEqual(3)

    describe 'removing a child with removeCustomChild', ->
      beforeEach -> @instanceRoot.removeCustomChild @instanceB

      it 'removes the child', ->
        expect(@instanceRoot.customChildrenSize).toEqual(1)

    describe 'finding a child with findCustomChild', ->
      it 'returns the index of the child', ->
        expect(@instanceRoot.findCustomChild @instanceB).toEqual(1)

      describe 'that is not present', ->
        beforeEach ->
          @instanceC = new @testClass 'c'

        it 'returns -1', ->
          expect(@instanceRoot.findCustomChild @instanceC).toEqual(-1)
