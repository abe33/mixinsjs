require '../../test_helper'

Formattable = require '../../../lib/mixinsjs/formattable'

describe 'Formattable', ->
  describe 'when called with extra arguments', ->
    it 'should create a mixin that provide a toString method using them', ->

      class TestClass
        Formattable('TestClass', 'a','b').attachTo TestClass
        constructor: (@a,@b) ->

      instance = new TestClass 5, 'foo'

      expect(instance.toString()).toBe('[TestClass(a=5, b=foo)]')

  describe 'when called without extra arguments', ->
    it 'should create a simpler toString method', ->

      class TestClass
        Formattable('TestClass').attachTo TestClass

      instance = new TestClass

      expect(instance.toString()).toBe('[TestClass]')

