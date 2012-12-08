require '../../test_helper'

Equatable = require '../../../lib/mixinsjs/equatable'

describe 'Equatable', ->
  describe 'when called with a list of properties name', ->
    it 'should return a mixin that define a equals method', ->

      class TestClass
        Equatable('a','b').attachTo TestClass
        constructor: (@a, @b) ->

      instance1 = new TestClass 1, 2
      instance2 = new TestClass 1, 2
      instance3 = new TestClass 2, 2

      expect(instance1.equals(instance2)).toBeTruthy()
      expect(instance1.equals(instance3)).toBeFalsy()
      expect(instance2.equals(instance3)).toBeFalsy()
