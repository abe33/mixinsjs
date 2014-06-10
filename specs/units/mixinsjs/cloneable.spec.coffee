
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
