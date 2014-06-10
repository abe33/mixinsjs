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
