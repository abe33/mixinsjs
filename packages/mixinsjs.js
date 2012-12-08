(function() {
  var BUILDS, Cloneable, Equatable, Formattable, Memoizable, Mixin, Module, Parameterizable, Sourcable, build, i, include, j,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.mixinsjs || (this.mixinsjs = {});

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

  /* src/mixinsjs/equatable.coffee */;


  Equatable = function() {
    var ConcreteEquatable, properties;
    properties = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return ConcreteEquatable = (function(_super) {

      __extends(ConcreteEquatable, _super);

      function ConcreteEquatable() {
        return ConcreteEquatable.__super__.constructor.apply(this, arguments);
      }

      ConcreteEquatable.prototype.equals = function(o) {
        var _this = this;
        return (o != null) && properties.every(function(p) {
          if (_this[p].equals != null) {
            return _this[p].equals(o[p]);
          } else {
            return o[p] === _this[p];
          }
        });
      };

      return ConcreteEquatable;

    })(Mixin);
  };

  /* src/mixinsjs/formattable.coffee */;


  Formattable = function() {
    var ConcretFormattable, classname, properties;
    classname = arguments[0], properties = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return ConcretFormattable = (function(_super) {

      __extends(ConcretFormattable, _super);

      function ConcretFormattable() {
        return ConcretFormattable.__super__.constructor.apply(this, arguments);
      }

      ConcretFormattable.prototype.toString = function() {
        var formattedProperties, p;
        if (properties.length === 0) {
          return "[" + classname + "]";
        } else {
          formattedProperties = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = properties.length; _i < _len; _i++) {
              p = properties[_i];
              _results.push("" + p + "=" + this[p]);
            }
            return _results;
          }).call(this);
          return "[" + classname + "(" + (formattedProperties.join(', ')) + ")]";
        }
      };

      ConcretFormattable.prototype.classname = function() {
        return classname;
      };

      return ConcretFormattable;

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

  /* src/mixinsjs/memoizable.coffee */;


  Memoizable = (function(_super) {

    __extends(Memoizable, _super);

    function Memoizable() {
      return Memoizable.__super__.constructor.apply(this, arguments);
    }

    Memoizable.prototype.memoized = function(prop) {
      var _ref;
      if (this.memoizationKey() === this.__memoizationKey__) {
        return ((_ref = this.__memo__) != null ? _ref[prop] : void 0) != null;
      } else {
        this.__memo__ = {};
        return false;
      }
    };

    Memoizable.prototype.memoFor = function(prop) {
      return this.__memo__[prop];
    };

    Memoizable.prototype.memoize = function(prop, value) {
      this.__memo__ || (this.__memo__ = {});
      this.__memoizationKey__ = this.memoizationKey();
      return this.__memo__[prop] = value;
    };

    Memoizable.prototype.memoizationKey = function() {
      return this.toString();
    };

    return Memoizable;

  })(Mixin);

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

  /* src/mixinsjs/parameterizable.coffee */;


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

  /* src/mixinsjs/sourcable.coffee */;


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

  this.mixinsjs.Mixin = Mixin;

  this.mixinsjs.Cloneable = Cloneable;

  this.mixinsjs.Equatable = Equatable;

  this.mixinsjs.Formattable = Formattable;

  this.mixinsjs.include = include;

  this.mixinsjs.Memoizable = Memoizable;

  this.mixinsjs.Mixin = Mixin;

  this.mixinsjs.Module = Module;

  this.mixinsjs.Parameterizable = Parameterizable;

  this.mixinsjs.Sourcable = Sourcable;

}).call(this);
