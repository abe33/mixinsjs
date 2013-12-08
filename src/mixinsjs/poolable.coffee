
#
class mixins.Poolable

  #### Poolable.extended

  # The two objects stores are created in the extended hook to avoid
  # that all the class extending `Poolable` shares the same instances.
  @extended: (klass) ->
    klass.usedInstances = []
    klass.unusedInstances = []

  #### Poolable.get

  # The `get` method returns an instance of the class.
  @get: (options={}) ->
    # Either retrieve or create the instance.
    if @unusedInstances.length > 0
      instance = @unusedInstances.shift()
    else
      instance = new this

    # Stores the instance in the used pool.
    @usedInstances.push instance

    # Init the instance and return it.
    instance.init(options)
    instance

  #### Poolable.release

  # The `release` method takes an instance and move it from the
  # the used pool to the unused pool.
  @release: (instance) ->
    # We can't release unused instances created using
    # the `new` operator without using `get`.
    unless instance in @usedInstances
      throw new Error "Can't release an unused instance"

    # The instance is removed from the used instances pool.
    index = @usedInstances.indexOf(instance)
    @usedInstances.splice(index, 1)

    # And then moved to the unused instances one.
    @unusedInstances.push instance

  #### Poolable::init

  # Default `init` implementation, just copy all the options
  # in the instance.
  init: (options={}) -> @[ k ] = v for k,v of options

  #### Poolable::dispose

  # Default `dispose` implementation, call the `release` method
  # on the instance constructor. A proper implementation should
  # take care of removing/cleaning all the instance properties.
  dispose: -> @constructor.release(this)
