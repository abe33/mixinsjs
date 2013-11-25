
Function::include = (mixins...) ->
  excluded = ['constructor', 'excluded']
  for mixin in mixins
    excl = excluded.concat()
    excl = excl.concat mixin::excluded if mixin::excluded?
    @::[k] = v for k,v of mixin.prototype when k not in excl
    mixin.included? this

  this

Function::extend = (mixins...) ->
  excluded = ['extended', 'excluded', 'included']
  for mixin in mixins
    excl = excluded.concat()
    excl = excl.concat mixin.excluded if mixin.excluded?
    @[k] = v for k,v of mixin when k not in excl
    mixin.extended? this

  this

Function::concern = (mixins...) ->
  @include.apply(this, mixins)
  @extend.apply(this, mixins)
