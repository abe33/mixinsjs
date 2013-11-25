describe mixins.Poolable, ->
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



