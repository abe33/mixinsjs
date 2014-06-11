describe 'mixins.Activable', ->
  describe 'when included in a class', ->
    beforeEach ->
      class TestClass
        @include mixins.Activable

        activated: ->
        deactivated: ->

      @instance = new TestClass
      spyOn(@instance, 'activated')
      spyOn(@instance, 'deactivated')

    it 'creates deactivated instances', ->
      expect(@instance.active).toBeFalsy()

    describe 'calling the activate method', ->
      beforeEach -> @instance.activate()

      it 'activates the instance', ->
        expect(@instance.active).toBeTruthy()

      it 'calls the activated hook', ->
        expect(@instance.activated).toHaveBeenCalled()

      describe 'activated a second time', ->
        beforeEach -> @instance.activate()

        it 'does not calls twice the activated hook', ->
          expect(@instance.activated.calls.count()).toEqual(1)

      describe 'then deactivated', ->
        beforeEach -> @instance.deactivate()

        it 'deactivates the instance', ->
          expect(@instance.active).toBeFalsy()

        it 'calls the deactivated hook', ->
          expect(@instance.deactivated).toHaveBeenCalled()

        describe 'deactivated a second time', ->
          beforeEach -> @instance.deactivate()

          it 'does not calls twice the deactivated hook', ->
            expect(@instance.deactivated.calls.count()).toEqual(1)
