require '../../test_helper'

Cloneable = require '../../../lib/mixinsjs/cloneable'

describe 'Cloneable', ->
  describe 'when called without argument', ->
    it 'should return a mixin that implement the clone method', ->
      constructorCalled = false
      constructorArg = null

      class TestClass
        Cloneable().attachTo TestClass
        constructor: (obj) ->
          constructorCalled = true
          constructorArg = obj

      obj = new TestClass

      constructorCalled = false
      constructorArg = null
      copy = obj.clone()

      expect(constructorCalled).toBeTruthy()
      expect(constructorArg).toBe(obj)
      expect(copy).toBeDefined()

  describe 'when called with arguments', ->
    it 'should return a mixin with a clone method that use these arguments', ->

      class TestClass
        Cloneable('a','b').attachTo TestClass
        constructor: (@a,@b) ->

      obj = new TestClass 5, 10

      copy = obj.clone()

      expect(copy.a).toBe(obj.a)
      expect(copy.b).toBe(obj.b)
