describe mixins.Formattable, ->
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

