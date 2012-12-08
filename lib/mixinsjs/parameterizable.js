(function() {
  var Mixin, Parameterizable,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Mixin = require('./mixin');

  Parameterizable = function(method, parameters, allowPartial) {
    var ConcreteParameterizable;
    if (allowPartial == null) {
      allowPartial = false;
    }
    return ConcreteParameterizable = (function(_super) {

      __extends(ConcreteParameterizable, _super);

      function ConcreteParameterizable() {
        return ConcreteParameterizable.__super__.constructor.apply(this, arguments);
      }

      ConcreteParameterizable.included = function(klass) {
        var f;
        f = function() {
          var args, firstArgumentIsObject, k, keys, n, o, output, strict, v, value, _i;
          args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), strict = arguments[_i++];
          if (typeof strict === 'number') {
            args.push(strict);
            strict = false;
          }
          output = {};
          o = arguments[0];
          n = 0;
          firstArgumentIsObject = (o != null) && typeof o === 'object';
          for (k in parameters) {
            v = parameters[k];
            value = firstArgumentIsObject ? o[k] : arguments[n++];
            output[k] = parseFloat(value);
            if (isNaN(output[k])) {
              if (strict) {
                keys = ((function() {
                  var _j, _len, _results;
                  _results = [];
                  for (_j = 0, _len = parameters.length; _j < _len; _j++) {
                    k = parameters[_j];
                    _results.push(k);
                  }
                  return _results;
                })()).join(', ');
                throw new Error("" + output + " doesn't match pattern {" + keys + "}");
              }
              if (allowPartial) {
                delete output[k];
              } else {
                output[k] = v;
              }
            }
          }
          return output;
        };
        klass[method] = f;
        return klass.prototype[method] = f;
      };

      return ConcreteParameterizable;

    })(Mixin);
  };

  module.exports = Parameterizable;

}).call(this);
