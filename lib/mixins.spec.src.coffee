
if typeof module is 'undefined'
  mixins = window.mixins
else
  global.mixins = mixins = require '../../lib/mixins'

xdescribe mixins.Aliasable, ->

  given 'testClass', ->
    class TestClass
      @extend mixins.Aliasable

      foo: -> 'foo'
      @getter 'bar', -> 'bar'

      @alias 'foo', 'oof', 'ofo'
      @alias 'bar', 'rab', 'bra'

  subject 'instance', -> new @testClass

  its 'oof', -> should equal @instance.foo
  its 'ofo', -> should equal @instance.foo

  its 'rab', -> should equal @instance.bar
  its 'bra', -> should equal @instance.bar

xdescribe mixins.AlternateCase, ->
  context 'mixed in a class using camelCase', ->

    given 'testClass', ->
      class TestClass
        @extend mixins.AlternateCase

        someProperty: true
        someMethod: ->

        @snakify()

    subject 'instance', -> new @testClass

    its 'some_property', -> should exist
    its 'some_method', -> should exist

  context 'mixed in a class using snake_case', ->

    given 'testClass', ->
      class TestClass
        @extend mixins.AlternateCase

        some_property: true
        some_method: ->

        @camelize()

    subject 'instance', -> new @testClass

    its 'some_property', -> should exist
    its 'someMethod', -> should exist


xdescribe mixins.Cloneable, ->
  context 'when called without arguments', ->
    given 'testClass', ->
      class TestClass
        @include mixins.Cloneable()

        constructor: (@self) ->

    given 'instance', -> new @testClass
    subject -> @instance.clone()

    it -> should exist
    its 'self', -> should be @instance

  context 'when called with arguments', ->
    given 'testClass', ->
      class TestClass
        @include mixins.Cloneable('a', 'b')

        constructor: (@a, @b) ->

    given 'instance', -> new @testClass 10, 'foo'
    subject -> @instance.clone()

    it -> should equal @instance

xdescribe mixins.Delegation, ->
  context 'on a class to delegate properties', ->
    given 'testClass', ->
      class TestClass
        @extend mixins.Delegation

        @delegate 'foo', 'bar', 'func', to: 'subObject'
        @delegate 'baz', to: 'subObject', prefix: true
        @delegate 'baz', to: 'subObject', prefix: true, case: 'snake'

        constructor: ->
          @subObject =
            foo: 'foo'
            bar: 'bar'
            baz: 'baz'
            func: -> @foo

    given 'instance', -> new @testClass

    context 'accessing a delegated property', ->

      specify -> expect(@instance.foo).to equal 'foo'
      specify -> expect(@instance.bar).to equal 'bar'

      context 'that hold a function', ->
        context 'calling the function', ->
          specify 'should be bound to the delegated object', ->
            expect(@instance.func()).to equal 'foo'

      context 'with prefix', ->
        specify -> expect(@instance.subObjectBaz).to equal 'baz'

        context 'and snake case', ->
          specify -> expect(@instance.subObject_baz).to equal 'baz'

    context 'writing on a delegated property', ->

      before ->
        @instance.foo = 'oof'
        @instance.bar = 'rab'

      specify -> expect(@instance.foo).to equal 'oof'
      specify -> expect(@instance.bar).to equal 'rab'

      context 'with prefix', ->
        before -> @instance.subObjectBaz = 'zab'

        specify -> expect(@instance.subObjectBaz).to equal 'zab'

        context 'and snake case', ->
          before -> @instance.subObject_baz = 'zab'

          specify -> expect(@instance.subObject_baz).to equal 'zab'


xdescribe mixins.Equatable, ->
  describe 'when called with a list of properties name', ->
    given 'testClass', ->
      class TestClass
        @include mixins.Equatable('a','b')
        constructor: (@a, @b) ->

    given 'instance1', -> new @testClass 1, 2
    given 'instance2', -> new @testClass 1, 2
    given 'instance3', -> new @testClass 2, 2

    specify 'instance1.equals instance2', ->
      @instance1.equals(@instance2).should be true

    specify 'instance1.equals instance3', ->
      @instance1.equals(@instance3).should be false

xdescribe mixins.Formattable, ->
  describe 'when called with extra arguments', ->
    given 'testClass', ->
      class TestClass
        @include mixins.Formattable('TestClass', 'a','b')

        constructor: (@a, @b) ->

    given 'instance', -> new @testClass 5, 'foo'
    subject -> @instance.toString()

    the 'toString method return', -> should equal '[TestClass(a=5, b=foo)]'

  describe 'when called without extra arguments', ->
    given 'testClass', ->
      class TestClass
        @include mixins.Formattable('TestClass')

    given 'instance', -> new @testClass
    subject -> @instance.toString()

    the 'toString method return', -> should equal '[TestClass]'


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

xdescribe mixins.Globalizable, ->
  given 'testClass', ->
    class TestClass
      @include mixins.Globalizable spectacular.global

      globalizable: [ 'method' ]

      property: 'foo'
      method: -> @property

  given 'instance', -> new @testClass

  context 'when globalized', ->
    before -> @instance.globalize()
    after -> @instance.unglobalize()

    specify 'the globalized method', ->
      expect(method()).to equal 'foo'

    whenPass ->
      context 'and then unglobalized', ->

        before -> @instance.unglobalize()

        specify 'the unglobalized method', ->
          expect(typeof method).to equal 'undefined'

xdescribe mixins.HasAncestors, ->
  given 'testClass', ->
    class TestClass
      @concern mixins.HasAncestors through: 'customParent'

      constructor: (@name, @customParent) ->

      toString: -> 'instance ' + @name

  given 'instanceA', -> new @testClass 'a'
  given 'instanceB', -> new @testClass 'b', @instanceA
  given 'instanceC', -> new @testClass 'c', @instanceB

  describe '#ancestors', ->
    subject -> String(@instanceC.ancestors)

    it -> should equal 'instance b,instance a'

  describe '#selfAndAncestors', ->
    subject -> String(@instanceC.selfAndAncestors)

    it -> should equal 'instance c,instance b,instance a'

  describe '.ancestorsScope', ->
    before -> @testClass.ancestorsScope 'isB', (p) -> p.name is 'b'

    subject -> String(@instanceC.isB)

    it -> should equal 'instance b'

xdescribe mixins.HasCollection, ->
  given 'testClass', ->
    class TestClass
      @concern mixins.HasCollection 'customChildren', 'customChild'

      constructor: (@name, @customChildren=[]) ->

  given 'instanceRoot', -> new @testClass 'root'
  given 'instanceA', -> new @testClass 'a'
  given 'instanceB', -> new @testClass 'b'

  before ->
    @instanceRoot.customChildren.push @instanceA
    @instanceRoot.customChildren.push @instanceB

  context 'included in class TestClass', ->

    subject -> @instanceRoot

    its 'customChildrenSize', -> should equal 2
    its 'customChildrenLength', -> should equal 2
    its 'customChildrenCount', -> should equal 2

    context 'using the generated customChildrenScope method', ->
      before ->
        @testClass.customChildrenScope 'childrenNamedB', (child) ->
          child.name is 'b'

      its 'childrenNamedB', -> should equal [ @instanceB ]

    context 'adding a child using addCustomChild', ->
      given 'instanceC', -> new @testClass 'c'

      before -> @instanceRoot.addCustomChild @instanceC

      its 'customChildrenSize', -> should equal 3

      context 'a second time', ->
        before -> @instanceRoot.addCustomChild @instanceC

        its 'customChildrenSize', -> should equal 3

    context 'removing a child with removeCustomChild', ->
      before -> @instanceRoot.removeCustomChild @instanceB

      its 'customChildrenSize', -> should equal 1

    context 'finding a child with findCustomChild', ->
      subject -> @instanceRoot.findCustomChild @instanceB

      it -> should equal 1

      context 'that is not present', ->
        given 'instanceC', -> new @testClass 'c'

        subject -> @instanceRoot.findCustomChild @instanceC

        it -> should equal -1

xdescribe mixins.HasNestedCollection, ->
  given 'testClass', ->
    class TestClass
      @concern mixins.HasCollection 'children', 'child'
      @concern mixins.HasNestedCollection 'descendants', through: 'children'

      constructor: (@name, @children=[]) ->

  given 'instanceRoot', -> new @testClass 'root'
  given 'instanceA', -> new @testClass 'a'
  given 'instanceB', -> new @testClass 'b'
  given 'instanceC', -> new @testClass 'c'

  before ->
    @instanceRoot.addChild @instanceA
    @instanceRoot.addChild @instanceB

    @instanceA.addChild @instanceC

  subject -> @instanceRoot

  its 'descendants', -> should equal [@instanceA, @instanceC, @instanceB]

  context 'using the descendantsScope method', ->
    before ->
      @testClass.descendantsScope 'descendantsNamedB', (item) ->
        item.name is 'b'

    its 'descendantsNamedB', -> should equal [ @instanceB ]

xdescribe mixins.Memoizable, ->
  given 'testClass', ->
    class TestClass
      @include mixins.Memoizable

      constructor: (@a=10, @b=20) ->

      getObject: ->
        return @memoFor 'getObject' if @memoized 'getObject'

        object = {@a, @b, c: @a + @b}

        @memoize 'getObject', object

      memoizationKey: -> "#{@a};#{@b}"

  subject 'instance', -> new @testClass

  given 'initial', -> @instance.getObject()
  given 'secondCall', -> @instance.getObject()

  specify 'the second object', -> @secondCall.should be @initial

  context 'when changing a property of the objet', ->
    before ->
      @initial

      @instance.a = 20

    given 'secondCall', -> @instance.getObject()

    specify 'the second object', -> @secondCall.shouldnt equal @initial

xdescribe mixins.Poolable, ->
  given 'testClass', ->
    class PoolableClass
      @concern mixins.Poolable

  context 'requesting two instances', ->
    before ->
      @instance1 = @testClass.get(x: 10, y: 20)
      @instance2 = @testClass.get(x: 20, y: 10)

    specify 'the used instances count', ->
      @testClass.usedInstances.length.should equal 2

    context 'then disposing an instance', ->
      before -> @instance2.dispose()

      specify 'the used instances count', ->
        @testClass.usedInstances.length.should equal 1

      specify 'the unused instances count', ->
        @testClass.unusedInstances.length.should equal 1

      context 'then requesting another instance', ->
        before ->
          @instance3 = @testClass.get(x: 200, y: 100)

        specify 'the used instances count', ->
          @testClass.usedInstances.length.should equal 2

        specify 'the returned instance', ->
          @instance3.should be @instance2

        context 'then disposing all the instances', ->
          before ->
            @instance1.dispose()
            @instance3.dispose()

          specify 'the used instances count', ->
            @testClass.usedInstances.length.should equal 0

          specify 'the unused instances count', ->
            @testClass.unusedInstances.length.should equal 2


xdescribe 'Sourcable', ->
  given 'testClass1', ->
    class TestClass1
      @include mixins.Sourcable('TestClass1', 'a', 'b')
      constructor: (@a, @b) ->

  given 'testClass2', ->
    class TestClass2
      @include mixins.Sourcable('TestClass2', 'a', 'b')
      constructor: (@a, @b) ->

  given 'instance', -> new @testClass2 [10, "o'foo"], new @testClass1 10, 5

  subject -> @instance.toSource()

  the 'toSource method return', ->
    should equal "new TestClass2([10,'o\\'foo'],new TestClass1(10,5))"
