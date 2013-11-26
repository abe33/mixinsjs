
Function::include = (mixins...) ->
  excluded = ['constructor', 'excluded']
  @__mixins__ ||= []

  @__super__ ||= {}
  @__super__ = Object.create @__super__

  for mixin in mixins
    @__mixins__.push mixin

    excl = excluded.concat()
    excl = excl.concat mixin::excluded if mixin::excluded?

    for k, v of mixin.prototype
      if k not in excl
        if @::[k]?
          v.__super__ ||= []
          v.__super__.push @::[k]

          v.__included__ ||= []
          v.__included__.push @

        @__super__[k] = v
        @::[k] = v

    mixin.included? this

  unless @::super?
    @::super = (args...) ->
      caller = arguments.caller or @super.caller
      if caller?

        if caller.__super__?
          value = caller.__super__[caller.__included__.indexOf @constructor]
          if value?
            value.apply(this, args)
          else
            throw new Error "No super method for #{caller}"
        else
          key = k for k,v of @constructor.prototype when v is caller
          if key?
            value = @constructor.__super__[key].apply(this, args)
          else
            throw new Error "No super method for #{caller}"
      else
        throw new Error "Super called with a caller"

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
