
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
