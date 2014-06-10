
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
