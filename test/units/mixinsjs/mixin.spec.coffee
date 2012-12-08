require '../../test_helper'

Mixin = require '../../../lib/mixinsjs/mixin'

describe 'Mixin', ->
  describe 'when extended by a class,', ->
    describe 'this class', ->
      it 'should be able to inject its content in another class', ->
        class TestMixin extends Mixin
          injectedMethod: ->

        class TestClass
          TestMixin.attachTo TestClass

        expect(TestClass::injectedMethod).toBe(TestMixin::injectedMethod)

    describe 'that define a included method,', ->
      describe 'when attached to another class its included method', ->
      it 'should be called with the target class', ->
        includedCalled = false
        includedTarget = null
        class TestMixin extends Mixin
          @included: (klass) ->
            includedCalled = true
            includedTarget = klass

        class TestClass
          TestMixin.attachTo TestClass

        expect(includedCalled).toBeTruthy()
        expect(includedTarget).toBe(TestClass)
