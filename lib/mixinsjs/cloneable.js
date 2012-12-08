(function() {
  var BUILDS, Cloneable, Mixin, build, i, j,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mixin = require('./mixin');

  BUILDS = (function() {
    var _i, _results;
    _results = [];
    for (i = _i = 0; _i <= 24; i = ++_i) {
      _results.push(new Function("return new arguments[0](" + (((function() {
        var _j, _results1;
        _results1 = [];
        for (j = _j = 0; 0 <= i ? _j <= i : _j >= i; j = 0 <= i ? ++_j : --_j) {
          if (j !== 0) {
            _results1.push("arguments[1][" + (j - 1) + "]");
          }
        }
        return _results1;
      })()).join(",")) + ");"));
    }
    return _results;
  })();

  build = function(klass, args) {
    var f;
    f = BUILDS[args != null ? args.length : 0];
    return f(klass, args);
  };

  Cloneable = function() {
    var ConcreteCloneable, properties;
    properties = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return ConcreteCloneable = (function(_super) {

      __extends(ConcreteCloneable, _super);

      function ConcreteCloneable() {
        return ConcreteCloneable.__super__.constructor.apply(this, arguments);
      }

      ConcreteCloneable.included = properties.length === 0 ? function(klass) {
        return klass.prototype.clone = function() {
          return new klass(this);
        };
      } : function(klass) {
        return klass.prototype.clone = function() {
          var _this = this;
          return build(klass, properties.map(function(p) {
            return _this[p];
          }));
        };
      };

      return ConcreteCloneable;

    })(Mixin);
  };

  module.exports = Cloneable;

}).call(this);
