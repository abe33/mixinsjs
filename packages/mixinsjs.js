(function() {
  var BUILDS, Cloneable, Mixin, Module, Sourcable, build, i, include, j,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.mixinsjs || (this.mixinsjs = {});

  /* src/mixinsjs/cloneable.coffee */;


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

  /* src/mixinsjs/include.coffee */;


  include = function() {
    var mixins;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (Object.prototype.toString.call(mixins[0]).indexOf('Array') >= 0) {
      mixins = mixins[0];
    }
    return {
      "in": function(klass) {
        return mixins.forEach(function(mixin) {
          return mixin.attachTo(klass);
        });
      }
    };
  };

  /* src/mixinsjs/mixin.coffee */;


  Mixin = (function() {

    function Mixin() {}

    Mixin.attachTo = function(klass) {
      var k, v, _ref;
      _ref = this.prototype;
      for (k in _ref) {
        v = _ref[k];
        if (k !== 'constructor') {
          klass.prototype[k] = v;
        }
      }
      return typeof this.included === "function" ? this.included(klass) : void 0;
    };

    return Mixin;

  })();

  /* src/mixinsjs/module.coffee */;


  Module = (function() {

    function Module() {}

    Module.include = function() {
      var mixin, mixins, _i, _len, _results;
      mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = mixins.length; _i < _len; _i++) {
        mixin = mixins[_i];
        _results.push(mixin.attachTo(this));
      }
      return _results;
    };

    return Module;

  })();

  /* src/mixinsjs/sourcable.coffee */;


  Sourcable = function() {
    var ConcretSourcable, name, signature;
    name = arguments[0], signature = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return ConcretSourcable = (function(_super) {
      var sourceFor;

      __extends(ConcretSourcable, _super);

      function ConcretSourcable() {
        return ConcretSourcable.__super__.constructor.apply(this, arguments);
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

      ConcretSourcable.prototype.toSource = function() {
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

      return ConcretSourcable;

    })(Mixin);
  };

  this.mixinsjs.Cloneable = Cloneable;

  this.mixinsjs.include = include;

  this.mixinsjs.Mixin = Mixin;

  this.mixinsjs.Module = Module;

  this.mixinsjs.Sourcable = Sourcable;

}).call(this);
