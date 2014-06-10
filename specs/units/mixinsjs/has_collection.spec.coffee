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
