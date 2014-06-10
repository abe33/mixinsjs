
describe 'a class without parent', ->
  describe 'with many mixin included', ->
    beforeEach ->
      class MixinA
        get: -> 'mixin A get'

      class MixinB
        get: -> @super() + ', mixin B get'

      class Dummy
        @include MixinA
        @include MixinB

        get: -> @super() + ', dummy get'

      @instance = new Dummy

    it 'calls the mixins super method in order', ->
      expect(@instance.get()).toEqual('mixin A get, mixin B get, dummy get')

describe 'a class with a parent', ->
  describe 'with no mixins', ->
    beforeEach ->
      class AncestorClass
        get: -> 'ancestor get'

      class Dummy extends AncestorClass
        get: -> @super() + ', child get'

      @instance = new Dummy

    it 'calls the ancestor method', ->
      expect(@instance.get()).toEqual('ancestor get, child get')

  describe 'with several mixins', ->
    beforeEach ->
      @ancestorClass = class AncestorClass
        get: -> 'ancestor get'

      @mixinA = class MixinA
        get: -> @super() + ', mixin A get'

      @mixinB = class MixinB
        get: -> @super() + ', mixin B get'

      class ChildClassA extends AncestorClass
        @include MixinA
        @include MixinB

        get: -> @super() + ', child get'

      class ChildClassB extends AncestorClass
        @include MixinB
        @include MixinA

      @instanceA = new ChildClassA
      @instanceB = new ChildClassB

    describe 'that overrides the mixin method', ->
      it 'calls the child and mixins methods up to the ancestor', ->
        expect(@instanceA.get()).toEqual('ancestor get, mixin A get, mixin B get, child get')

    describe 'that do not overrides the mixin method', ->
      it 'calls the last mixin method and up to the ancestor class', ->
        expect(@instanceB.get()).toEqual('ancestor get, mixin B get, mixin A get')

    describe 'when a mixin was included more than once', ->
      it 'does not mix up the mixin hierarchy', ->
        expect(@instanceA.get()).toEqual('ancestor get, mixin A get, mixin B get, child get')
        expect(@instanceB.get()).toEqual('ancestor get, mixin B get, mixin A get')

    describe 'calling this.super in a child method without super', ->
      beforeEach ->
        ancestor = @ancestorClass
        mixinA = @mixinA

        class ChildClass extends ancestor
          @include mixinA

          foo: -> @super()

        @instance = new ChildClass

      it 'raises an exception', ->
        expect(-> @instance.foo()).toThrow()

  describe 'that have a virtual property', ->
    beforeEach ->
      class AncestorClass
        @accessor 'foo', {
          get: -> @__foo
          set: (value) -> @__foo = value
        }

      class Mixin
        @accessor 'foo', {
          get: -> @super() + ', in mixin'
          set: (value) -> @super value
        }

      class TestClass extends AncestorClass
        @include Mixin

        @accessor 'foo', {
          get: -> @super() + ', in child class'
          set: (value) -> @super value
        }

      @instance = new TestClass
      @instance.foo = 'bar'

    it 'calls the corresponding super accessor method', ->
      expect(@instance.foo).toEqual('bar, in mixin, in child class')

  describe 'that have a partially defined virtual property', ->
    beforeEach ->
      class AncestorClass
        @accessor 'foo', {
          set: (value) -> @__foo = value
        }

      class Mixin
        @accessor 'foo', {
          get: -> @__foo + ', in mixin'
        }

      class TestClass extends AncestorClass
        @include Mixin

        @accessor 'foo', {
          get: -> @super() + ', in child class'
          set: (value) -> @super value
        }

      @instance = new TestClass
      @instance.foo = 'bar'

    it 'creates a new accessor mixing the parent setter and the mixed getter', ->
      expect(@instance.foo).toEqual('bar, in mixin, in child class')

  describe 'and a mixin with a class method override', ->
    beforeEach ->
      class AncestorClass
        @get: -> 'bar'

      class MixinA
        @get: -> @super() + ', in mixin A get'

      class MixinB
        @get: -> @super() + ', in mixin B get'

      class @TestClass extends AncestorClass
        @extend MixinA
        @extend MixinB

        @get: ->
          @super() + ', in child get'

    it 'calls the super class method from mixins up to the ancestor class', ->
      expect(@TestClass.get()).toEqual('bar, in mixin A get, in mixin B get, in child get')
