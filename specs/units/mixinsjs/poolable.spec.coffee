describe 'mixins.Poolable', ->
  beforeEach ->
    @testClass = class PoolableClass
      @concern mixins.Poolable

  describe 'requesting two instances', ->
    beforeEach ->
      @instance1 = @testClass.get(x: 10, y: 20)
      @instance2 = @testClass.get(x: 20, y: 10)

    it 'creates two instances and returns them', ->
      expect(@testClass.usedInstances.length).toEqual(2)

    describe 'then disposing an instance', ->
      beforeEach -> @instance2.dispose()

      it 'removes the instance from the used list', ->
        expect(@testClass.usedInstances.length).toEqual(1)

      it 'adds the disposed instance in the unused list', ->
        expect(@testClass.unusedInstances.length).toEqual(1)

      describe 'then requesting another instance', ->
        beforeEach ->
          @instance3 = @testClass.get(x: 200, y: 100)

        it 'reuses a previously created instance', ->
          expect(@testClass.usedInstances.length).toEqual(2)
          expect(@testClass.unusedInstances.length).toEqual(0)
          expect(@instance3).toBe(@instance2)

        describe 'then disposing all the instances', ->
          beforeEach ->
            @instance1.dispose()
            @instance3.dispose()

          it 'removes all the instances from the used list', ->
            expect(@testClass.usedInstances.length).toEqual(0)

          it 'adds these instances in the unused list', ->
            expect(@testClass.unusedInstances.length).toEqual(2)
