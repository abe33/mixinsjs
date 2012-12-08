# @toc
Mixin = require './mixin'

## Parameterizable

#
Parameterizable = (method, parameters, allowPartial=false) ->
  #
  class ConcreteParameterizable extends Mixin
    ##### Parameterizable.included
    #
    @included: (klass) ->
      f = (args..., strict)->
        (args.push(strict); strict = false) if typeof strict is 'number'
        output = {}

        o = arguments[0]
        n = 0
        firstArgumentIsObject = o? and typeof o is 'object'

        for k,v of parameters
          value = if firstArgumentIsObject then o[k] else arguments[n++]
          output[k] = parseFloat value

          if isNaN output[k]
            if strict
              keys = (k for k in parameters).join ', '
              throw new Error "#{output} doesn't match pattern {#{keys}}"
            if allowPartial then delete output[k] else output[k] = v

        output

      klass[method] = f
      klass::[method] = f

module.exports = Parameterizable
