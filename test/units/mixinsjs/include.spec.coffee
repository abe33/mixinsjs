require '../../test_helper'

include = require '../../../lib/mixinsjs/include'
Mixin = require '../../../lib/mixinsjs/mixin'

describe 'include', ->
  describe 'when called with a mixin', ->
    it 'should return an object with a in method', ->
      included1Called = false
      included2Called = false

      class TestMixin1 extends Mixin
        @included: -> included1Called = true

      class TestMixin2 extends Mixin
        @included: -> included2Called = true

      class TestClass

      res = include TestMixin1, TestMixin2

      expect(res.in).toBeDefined()

      res.in TestClass

      expect(included1Called).toBeTruthy()
      expect(included2Called).toBeTruthy()
