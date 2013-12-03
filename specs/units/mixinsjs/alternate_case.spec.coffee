describe mixins.AlternateCase, ->
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
