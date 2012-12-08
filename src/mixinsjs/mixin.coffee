# @toc

## Mixin

# The `Mixin` class provides the default behavior of mixins.
# Any class can extends `Mixin` and gain the ability to be mixed
# into another class.
#
#     class DummyMixin extends Mixin
#       sayHello: -> 'Hello World'
#
# The mixin can then be included into any class using its `attachTo`
# method.
#
#     class Dummy
#       DummyMixin.attachTo Dummy
#
# Any members of the mixin's prototype will be pasted into the
# class prototype. The properties of the class itself are not
# copied to the target class.
#
#     dummy = new Dummy()
#     dummy.sayHello() # 'Hello World'
#
# A mixin can also define a static `included` method that will
# then be called each time the mixin is included into a class.
#
#     class DummyMixin extends Mixin
#       @included: (klass) ->
#          # ... do something with the class
class Mixin

  ##### Mixin.attachTo
  #
  # Copy all the properties defined on the mixin prototype
  # into the passed-in class.
  #
  #     class Dummy
  #       DummyMixin.attachTo Dummy
  @attachTo: (klass) ->
    klass::[k] = v for k,v of this.prototype when k isnt 'constructor'
    @included? klass

module.exports = Mixin
