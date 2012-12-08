(function() {
  var Mixin, Sourcable,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mixin = require('./mixin');

  Sourcable = function() {
    var ConcreteSourcable, name, signature;
    name = arguments[0], signature = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return ConcreteSourcable = (function(_super) {
      var sourceFor;

      __extends(ConcreteSourcable, _super);

      function ConcreteSourcable() {
        return ConcreteSourcable.__super__.constructor.apply(this, arguments);
      }

      sourceFor = function(value) {
        var isArray;
        switch (typeof value) {
          case 'object':
            isArray = Object.prototype.toString.call(value).indexOf('Array') !== -1;
            if (value.toSource != null) {
              return value.toSource();
            } else {
              if (isArray) {
                return "[" + (value.map(function(el) {
                  return sourceFor(el);
                })) + "]";
              } else {
                return value;
              }
            }
            break;
          case 'string':
            if (value.toSource != null) {
              return value.toSource();
            } else {
              return "'" + (value.replace("'", "\\'")) + "'";
            }
            break;
          default:
            return value;
        }
      };

      ConcreteSourcable.prototype.toSource = function() {
        var arg, args;
        args = ((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = signature.length; _i < _len; _i++) {
            arg = signature[_i];
            _results.push(this[arg]);
          }
          return _results;
        }).call(this)).map(function(o) {
          return sourceFor(o);
        });
        return "new " + name + "(" + (args.join(',')) + ")";
      };

      return ConcreteSourcable;

    })(Mixin);
  };

  module.exports = Sourcable;

}).call(this);
