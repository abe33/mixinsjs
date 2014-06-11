
if typeof module is 'undefined'
  mixins = window.mixins
else
  global.mixins = mixins = require '../../lib/mixins'

describe 'mixins.Activable', ->
  describe 'when included in a class', ->
    beforeEach ->
      class TestClass
        @include mixins.Activable

        activated: ->
        deactivated: ->

      @instance = new TestClass
      spyOn(@instance, 'activated')
      spyOn(@instance, 'deactivated')

    it 'creates deactivated instances', ->
      expect(@instance.active).toBeFalsy()

    describe 'calling the activate method', ->
      beforeEach -> @instance.activate()

      it 'activates the instance', ->
        expect(@instance.active).toBeTruthy()

      it 'calls the activated hook', ->
        expect(@instance.activated).toHaveBeenCalled()

      describe 'then deactivated', ->
        beforeEach -> @instance.deactivate()
        
        it 'deactivates the instance', ->
          expect(@instance.active).toBeFalsy()

        it 'calls the deactivated hook', ->
          expect(@instance.deactivated).toHaveBeenCalled()

describe 'mixins.Aliasable', ->
  beforeEach ->
    class TestClass
      @extend mixins.Aliasable

      foo: -> 'foo'
      @getter 'bar', -> 'bar'

      @alias 'foo', 'oof', 'ofo'
      @alias 'bar', 'rab', 'bra'

    @instance = new TestClass

  it 'creates aliases for object properties', ->
    expect(@instance.oof).toEqual(@instance.foo)
    expect(@instance.ofo).toEqual(@instance.foo)
    expect(@instance.rab).toEqual(@instance.bar)
    expect(@instance.bra).toEqual(@instance.bar)

describe 'mixins.AlternateCase', ->
  describe 'mixed in a class using camelCase', ->
    beforeEach ->
      class TestClass
        @extend mixins.AlternateCase

        someProperty: true
        someMethod: ->

        @snakify()

      @instance = new TestClass

    it 'creates properties with snake case', ->
      expect(@instance.some_property).toBeDefined()
      expect(@instance.some_method).toBeDefined()

  describe 'mixed in a class using snake_case', ->
    beforeEach ->
      class TestClass
        @extend mixins.AlternateCase

        some_property: true
        some_method: ->

        @camelize()

      @instance = new TestClass

    it 'creates properties with camel case', ->
      expect(@instance.some_property).toBeDefined()
      expect(@instance.someMethod).toBeDefined()


describe 'mixins.Cloneable', ->
  describe 'when called without arguments', ->
    beforeEach ->
      class TestClass
        @include mixins.Cloneable()

        constructor: (@self) ->

      @instance = new TestClass

    it 'creates a copy by passing the reference in the copy constructor', ->
      clone = @instance.clone()

      expect(clone).toBeDefined()
      expect(clone.self).toBe(@instance)

  describe 'when called with arguments', ->
    beforeEach ->
      class TestClass
        @include mixins.Cloneable('a', 'b')

        constructor: (@a, @b) ->

      @instance = new TestClass 10, 'foo'

    it 'creates a copy of the object', ->
      clone = @instance.clone()

      expect(clone).toBeDefined()
      expect(clone).toEqual(@instance)
      expect(clone).not.toBe(@instance)

describe 'mixins.Delegation', ->
  describe 'included in a class with delegated properties', ->
    beforeEach ->
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

      @instance = new TestClass

    describe 'when accessing a delegated property', ->
      it 'returns the composed instance value', ->
        expect(@instance.foo).toEqual('foo')
        expect(@instance.bar).toEqual('bar')

      describe 'that hold a function', ->
        describe 'calling the function', ->
          it 'binds the methods to the delegated object', ->
            expect(@instance.func()).toEqual('foo')

      describe 'with prefix', ->
        it 'returns the composed instance value', ->
          expect(@instance.subObjectBaz).toEqual('baz')

        describe 'and snake case', ->
          it 'returns the composed instance value', ->
            expect(@instance.subObject_baz).toEqual('baz')

    describe 'writing on a delegated property', ->

      beforeEach ->
        @instance.foo = 'oof'
        @instance.bar = 'rab'

      it 'writes in the composed instance properties', ->
        expect(@instance.foo).toEqual('oof')
        expect(@instance.bar).toEqual('rab')

      describe 'with prefix', ->
        beforeEach -> @instance.subObjectBaz = 'zab'

        it 'writes in the composed instance properties', ->
          expect(@instance.subObjectBaz).toEqual('zab')

        describe 'and snake case', ->

          beforeEach -> @instance.subObject_baz = 'zab'

          it 'writes in the composed instance properties', ->
            expect(@instance.subObject_baz).toEqual('zab')


describe 'mixins.Equatable', ->
  describe 'when called with a list of properties name', ->
    beforeEach ->
      class TestClass
        @include mixins.Equatable('a','b')
        constructor: (@a, @b) ->

      @instance1 = new TestClass 1, 2
      @instance2 = new TestClass 1, 2
      @instance3 = new TestClass 2, 2

    it 'returns true with two similar instancew', ->
      expect(@instance1.equals(@instance2)).toBeTruthy()

    it 'returns false with tow different instances', ->
      expect(@instance1.equals(@instance3)).toBeFalsy()

describe 'mixins.Formattable', ->
  describe 'when called with extra arguments', ->
    beforeEach ->
      class TestClass
        @include mixins.Formattable('TestClass', 'a','b')

        constructor: (@a, @b) ->

      @instance = new TestClass 5, 'foo'

    it 'returns a formatted string with extra details', ->
      expect(@instance.toString()).toEqual('[TestClass(a=5, b=foo)]')

  describe 'when called without extra arguments', ->
    beforeEach ->
      class TestClass
        @include mixins.Formattable('TestClass')

      @instance = new TestClass

    it 'returns a formatted string without any details', ->
      expect(@instance.toString()).toEqual('[TestClass]')


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

describe 'mixins.Globalizable', ->
  beforeEach ->
    class TestClass
      @include mixins.Globalizable global ? window

      globalizable: [ 'method' ]

      property: 'foo'
      method: -> @property

    @instance = new TestClass

  describe 'when globalized', ->
    beforeEach -> @instance.globalize()
    afterEach -> @instance.unglobalize()

    it 'creates methods on the global object', ->
      expect(method()).toEqual('foo')

    describe 'and then unglobalized', ->
      beforeEach -> @instance.unglobalize()

      it 'removes the methods from the global object', ->
        expect(typeof method).toEqual('undefined')

describe 'mixins.HasAncestors', ->
  beforeEach ->
    @testClass = class TestClass
      @concern mixins.HasAncestors through: 'customParent'

      constructor: (@name, @customParent) ->

      toString: -> 'instance ' + @name

    @instanceA = new TestClass 'a'
    @instanceB = new TestClass 'b', @instanceA
    @instanceC = new TestClass 'c', @instanceB

  describe '#ancestors', ->

    it 'returns an array of the object ancestors', ->
      expect(@instanceC.ancestors).toEqual([
        @instanceB
        @instanceA
      ])

  describe '#selfAndAncestors', ->
    it 'returns an array of the object and its ancestors', ->
      expect(@instanceC.selfAndAncestors).toEqual([
        @instanceC
        @instanceB
        @instanceA
      ])

  describe '.ancestorsScope', ->
    beforeEach ->
      @testClass.ancestorsScope 'isB', (p) -> p.name is 'b'

    it 'should creates a scope filtering the ancestors', ->
      expect(@instanceC.isB).toEqual([@instanceB])

describe 'mixins.HasCollection', ->
  beforeEach ->
    @testClass = class TestClass
      @concern mixins.HasCollection 'customChildren', 'customChild'

      constructor: (@name, @customChildren=[]) ->

    @instanceRoot = new TestClass 'root'
    @instanceA = new TestClass 'a'
    @instanceB = new TestClass 'b'

    @instanceRoot.customChildren.push @instanceA
    @instanceRoot.customChildren.push @instanceB

  describe 'included in class TestClass', ->

    it 'provides properties to count children', ->
      expect(@instanceRoot.customChildrenSize).toEqual(2)
      expect(@instanceRoot.customChildrenLength).toEqual(2)
      expect(@instanceRoot.customChildrenCount).toEqual(2)

    describe 'using the generated customChildrenScope method', ->
      beforeEach ->
        @testClass.customChildrenScope 'childrenNamedB', (child) ->
          child.name is 'b'

      it 'creates a property returning a filtered array of children', ->
        expect(@instanceRoot.childrenNamedB).toEqual([ @instanceB ])

    describe 'adding a child using addCustomChild', ->

      beforeEach ->
        @instanceC = new @testClass 'c'
        @instanceRoot.addCustomChild @instanceC

      it 'updates the children count', ->
        expect(@instanceRoot.customChildrenSize).toEqual(3)

      describe 'a second time', ->
        beforeEach -> @instanceRoot.addCustomChild @instanceC

        it 'does not add the instance', ->
          expect(@instanceRoot.customChildrenSize).toEqual(3)

    describe 'removing a child with removeCustomChild', ->
      beforeEach -> @instanceRoot.removeCustomChild @instanceB

      it 'removes the child', ->
        expect(@instanceRoot.customChildrenSize).toEqual(1)

    describe 'finding a child with findCustomChild', ->
      it 'returns the index of the child', ->
        expect(@instanceRoot.findCustomChild @instanceB).toEqual(1)

      describe 'that is not present', ->
        beforeEach ->
          @instanceC = new @testClass 'c'

        it 'returns -1', ->
          expect(@instanceRoot.findCustomChild @instanceC).toEqual(-1)

describe 'mixins.HasNestedCollection', ->
  beforeEach ->
    @testClass = class TestClass
      @concern mixins.HasCollection 'children', 'child'
      @concern mixins.HasNestedCollection 'descendants', through: 'children'

      constructor: (@name, @children=[]) ->

    @instanceRoot =  new @testClass 'root'
    @instanceA =  new @testClass 'a'
    @instanceB =  new @testClass 'b'
    @instanceC =  new @testClass 'c'

    @instanceRoot.addChild @instanceA
    @instanceRoot.addChild @instanceB

    @instanceA.addChild @instanceC

  it 'returns all its descendants in a single array', ->
    expect(@instanceRoot.descendants).toEqual([
      @instanceA
      @instanceC
      @instanceB
    ])

  describe 'using the descendantsScope method', ->
    beforeEach ->
      @testClass.descendantsScope 'descendantsNamedB', (item) ->
        item.name is 'b'

    it 'creates a method returning a filtered array of descendants', ->
      expect(@instanceRoot.descendantsNamedB).toEqual([ @instanceB ])

describe 'mixins.Memoizable', ->
  beforeEach ->
    @testClass = class TestClass
      @include mixins.Memoizable

      constructor: (@a=10, @b=20) ->

      getObject: ->
        return @memoFor 'getObject' if @memoized 'getObject'

        object = {@a, @b, c: @a + @b}

        @memoize 'getObject', object

      memoizationKey: -> "#{@a};#{@b}"

    @instance = new @testClass
    @initial = @instance.getObject()
    @secondCall = @instance.getObject()

  it 'stores the result of the first call and return it in the second', ->
    expect(@secondCall).toBe(@initial)

  describe 'when changing a property of the objet', ->
    beforeEach ->
      @instance.a = 20

    it 'clears the memoized value', ->
      expect(@instance.getObject()).not.toEqual(@initial)

describe 'mixins.Poolable', ->
  beforeEach ->
    @testClass = class PoolableClass
      @concern mixins.Poolable

  describe 'requesting two instances', ->
    beforeEach ->
      @instance1 = @testClass.get(x: 10, y: 20)
      @instance2 = @testClass.get(x: 20, y: 10)

    it 'creates two instances and returns them', ->
      expect(@testClass.usedInstances.length).toEqual(2)

    describe 'then disposing an instance', ->
      beforeEach -> @instance2.dispose()

      it 'removes the instance from the used list', ->
        expect(@testClass.usedInstances.length).toEqual(1)

      it 'adds the disposed instance in the unused list', ->
        expect(@testClass.unusedInstances.length).toEqual(1)

      describe 'then requesting another instance', ->
        beforeEach ->
          @instance3 = @testClass.get(x: 200, y: 100)

        it 'reuses a previously created instance', ->
          expect(@testClass.usedInstances.length).toEqual(2)
          expect(@testClass.unusedInstances.length).toEqual(0)
          expect(@instance3).toBe(@instance2)

        describe 'then disposing all the instances', ->
          beforeEach ->
            @instance1.dispose()
            @instance3.dispose()

          it 'removes all the instances from the used list', ->
            expect(@testClass.usedInstances.length).toEqual(0)

          it 'adds these instances in the unused list', ->
            expect(@testClass.unusedInstances.length).toEqual(2)


describe 'mixins.Sourcable', ->
  beforeEach ->
    @testClass1 = class TestClass1
      @include mixins.Sourcable('TestClass1', 'a', 'b')
      constructor: (@a, @b) ->

    @testClass2 = class TestClass2
      @include mixins.Sourcable('TestClass2', 'a', 'b')
      constructor: (@a, @b) ->

    @instance = new @testClass2 [10, "o'foo"], new @testClass1 10, 5

  it 'returns the source of the object', ->
    expect(@instance.toSource()).toEqual("new TestClass2([10,'o\\'foo'],new TestClass1(10,5))")
