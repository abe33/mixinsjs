require '../../test_helper'

Module = require '../../../lib/mixinsjs/module'

describe 'Module', ->
  describe 'when extended by another class', ->
    it 'should provide an include static method to insert mixins', ->
      attachTo1Called = false
      attachTo2Called = false
      mixin1 = attachTo: -> attachTo1Called = true
      mixin2 = attachTo: -> attachTo2Called = true

      class TestModule extends Module
        @include mixin1, mixin2

      expect(attachTo1Called).toBeTruthy()
      expect(attachTo2Called).toBeTruthy()
