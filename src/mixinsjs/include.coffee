
include = (mixins...) ->
  if Object::toString.call(mixins[0]).indexOf('Array') >= 0
    mixins = mixins[0]

  in: (klass) -> mixins.forEach (mixin) -> mixin.attachTo klass

module.exports = include
