
describe 'Sourcable', ->
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
