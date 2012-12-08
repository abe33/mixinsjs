require '../../test_helper'

Sourcable = require '../../../lib/mixinsjs/sourcable'

describe 'Sourcable', ->
  describe 'when called with arguments', ->
    it 'should create a mixin that serialize an instance', ->

      class TestClass1
        Sourcable('TestClass1', 'a', 'b').attachTo TestClass1
        constructor: (@a, @b) ->

      class TestClass2
        Sourcable('TestClass2', 'a', 'b').attachTo TestClass2
        constructor: (@a, @b) ->

      instance = new TestClass2 [10, "o'foo"], new TestClass1 10, 5
      source = instance.toSource()

      expect(source)
      .toBe("new TestClass2([10,'o\\'foo'],new TestClass1(10,5))")
