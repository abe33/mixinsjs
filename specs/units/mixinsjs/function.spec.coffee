
describe 'a class without parent', ->
  given 'mixinA', ->
    class MixinA
      get: -> 'mixin A get'

  given 'mixinB', ->
    class MixinB
      get: -> @super() + ', mixin B get'

  context 'with many mixin included', ->
    given 'dummyClass', ->
      mixinA = @mixinA
      mixinB = @mixinB

      class Dummy
        @include mixinA
        @include mixinB

        get: -> @super() + ', dummy get'

    given 'instance', -> new @dummyClass

    subject -> @instance.get()

    it -> should equal 'mixin A get, mixin B get, dummy get'

describe 'a class with a parent', ->
  given 'ancestorClass', ->
    class AncestorClass
      get: -> 'ancestor get'

  context 'and several mixins', ->
    given 'mixinA', ->
      class MixinA
        get: -> @super() + ', mixin A get'

    given 'mixinB', ->
      class MixinB
        get: -> @super() + ', mixin B get'

    given 'childClassA', ->
      mixinA = @mixinA
      mixinB = @mixinB
      ancestor = @ancestorClass

      class ChildClassA extends ancestor
        @include mixinA
        @include mixinB

        get: -> @super() + ', child get'

    given 'childClassB', ->
      mixinA = @mixinA
      mixinB = @mixinB
      ancestor = @ancestorClass

      class ChildClassB extends ancestor
        @include mixinB
        @include mixinA

    given 'instanceA', -> new @childClassA
    given 'instanceB', -> new @childClassB

    context 'that overrides the mixin method', ->
      subject -> @instanceA.get()

      it -> should equal 'ancestor get, mixin A get, mixin B get, child get'

    context 'that do not overrides the mixin method', ->
      subject -> @instanceB.get()

      it -> should equal 'ancestor get, mixin B get, mixin A get'

    context 'when a mixin was included more than once', ->
      before ->
        @instanceA and @instanceB

        @getA = @instanceA.get()
        @getB = @instanceB.get()

      specify 'the first class get result', ->
        @getA.should equal 'ancestor get, mixin A get, mixin B get, child get'

      specify 'the second class get result', ->
        @getB.should equal 'ancestor get, mixin B get, mixin A get'

    context 'calling this.super in a child method without super', ->
      given 'childClass', ->
        ancestor = @ancestorClass
        mixinA = @mixinA

        class ChildClass extends ancestor
          @include mixinA

          foo: -> @super()

      given 'instance', -> new @childClass

      specify '', ->
        @instance.foo.should throwAnError().inContext(@instance)

  context 'that have a virtual property', ->
    given 'ancestor', ->
      class AncestorClass
        @accessor 'foo', {
          get: -> @__foo
          set: (value) -> @__foo = value
        }

    given 'mixin', ->
      class Mixin
        @accessor 'foo', {
          get: -> @super() + ', in mixin'
          set: (value) -> @super value
        }

    given 'testClass', ->
      ancestor = @ancestor
      mixin = @mixin

      class TestClass extends ancestor
        @include mixin

        @accessor 'foo', {
          get: -> @super() + ', in child class'
          set: (value) -> @super value
        }

    subject 'instance', -> new @testClass

    before -> @instance.foo = 'bar'

    its 'foo', -> should equal 'bar, in mixin, in child class'

  context 'that have a partially defined virtual property', ->
    given 'ancestor', ->
      class AncestorClass
        @accessor 'foo', {
          set: (value) -> @__foo = value
        }

    given 'mixin', ->
      class Mixin
        @accessor 'foo', {
          get: -> @__foo + ', in mixin'
        }

    given 'testClass', ->
      ancestor = @ancestor
      mixin = @mixin

      class TestClass extends ancestor
        @include mixin

        @accessor 'foo', {
          get: -> @super() + ', in child class'
          set: (value) -> @super value
        }

    subject 'instance', -> new @testClass

    before -> @instance.foo = 'bar'

    its 'foo', -> should equal 'bar, in mixin, in child class'

  context 'and a mixin with a class method override', ->
    given 'ancestorClass', ->
      class AncestorClass
        @get: -> 'bar'

    given 'mixinA', ->
      class MixinA
        @get: -> @super() + ', in mixin A get'

    given 'mixinB', ->
      class MixinB
        @get: -> @super() + ', in mixin B get'

    given 'testClass', ->
      ancestor = @ancestorClass
      mixinA = @mixinA
      mixinB = @mixinB

      class TestClass extends ancestor
        @extend mixinA
        @extend mixinB

        @get: ->
          console.log @__mixins__
          @super() + ', in child get'

    subject -> @testClass.get()

    it -> should equal 'bar, in mixin B get, in mixin A get, in child get'
