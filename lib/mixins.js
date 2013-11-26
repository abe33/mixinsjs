(function() {
  var BUILDS, build, exports, i, isCommonJS, j, mixins,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  isCommonJS = typeof module !== "undefined";

  if (isCommonJS) {
    exports = module.exports || {};
  } else {
    exports = window.mixins = {};
  }

  mixins = exports;

  mixins.version = '0.1.2';

  mixins.deprecated = function(message) {
    var caller, deprecatedMethodCallerFile, deprecatedMethodCallerName, e, parseLine, s, _ref;
    parseLine = function(line) {
      var f, m, o, _ref, _ref1, _ref2, _ref3;
      if (line.indexOf('@') > 0) {
        if (line.indexOf('</') > 0) {
          _ref = /<\/([^@]+)@(.)+$/.exec(line), m = _ref[0], o = _ref[1], f = _ref[2];
        } else {
          _ref1 = /@(.)+$/.exec(line), m = _ref1[0], f = _ref1[1];
        }
      } else {
        if (line.indexOf('(') > 0) {
          _ref2 = /at\s+([^\s]+)\s*\(([^\)])+/.exec(line), m = _ref2[0], o = _ref2[1], f = _ref2[2];
        } else {
          _ref3 = /at\s+([^\s]+)/.exec(line), m = _ref3[0], f = _ref3[1];
        }
      }
      return [o, f];
    };
    e = new Error();
    caller = '';
    if (e.stack != null) {
      s = e.stack.split('\n');
      _ref = parseLine(s[3]), deprecatedMethodCallerName = _ref[0], deprecatedMethodCallerFile = _ref[1];
      caller = deprecatedMethodCallerName ? " (called from " + deprecatedMethodCallerName + " at " + deprecatedMethodCallerFile + ")" : "(called from " + deprecatedMethodCallerFile + ")";
    }
    return console.log("DEPRECATION WARNING: " + message + caller);
  };

  mixins.deprecated._name = 'deprecated';

  Function.prototype.include = function() {
    var excl, excluded, k, mixin, mixins, v, _i, _len, _ref;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    excluded = ['constructor', 'excluded'];
    this.__mixins__ || (this.__mixins__ = []);
    this.__super__ || (this.__super__ = {});
    this.__super__ = Object.create(this.__super__);
    for (_i = 0, _len = mixins.length; _i < _len; _i++) {
      mixin = mixins[_i];
      this.__mixins__.push(mixin);
      excl = excluded.concat();
      if (mixin.prototype.excluded != null) {
        excl = excl.concat(mixin.prototype.excluded);
      }
      _ref = mixin.prototype;
      for (k in _ref) {
        v = _ref[k];
        if (__indexOf.call(excl, k) < 0) {
          if (this.prototype[k] != null) {
            v.__super__ || (v.__super__ = []);
            v.__super__.push(this.prototype[k]);
            v.__included__ || (v.__included__ = []);
            v.__included__.push(this);
          }
          this.__super__[k] = v;
          this.prototype[k] = v;
        }
      }
      if (typeof mixin.included === "function") {
        mixin.included(this);
      }
    }
    if (this.prototype["super"] == null) {
      this.prototype["super"] = function() {
        var args, caller, key, value, _ref1;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        caller = arguments.caller || this["super"].caller;
        if (caller != null) {
          if (caller.__super__ != null) {
            value = caller.__super__[caller.__included__.indexOf(this.constructor)];
            if (value != null) {
              return value.apply(this, args);
            } else {
              throw new Error("No super method for " + caller);
            }
          } else {
            _ref1 = this.constructor.prototype;
            for (k in _ref1) {
              v = _ref1[k];
              if (v === caller) {
                key = k;
              }
            }
            if (key != null) {
              return value = this.constructor.__super__[key].apply(this, args);
            } else {
              throw new Error("No super method for " + caller);
            }
          }
        } else {
          throw new Error("Super called with a caller");
        }
      };
    }
    return this;
  };

  Function.prototype.extend = function() {
    var excl, excluded, k, mixin, mixins, v, _i, _len;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    excluded = ['extended', 'excluded', 'included'];
    for (_i = 0, _len = mixins.length; _i < _len; _i++) {
      mixin = mixins[_i];
      excl = excluded.concat();
      if (mixin.excluded != null) {
        excl = excl.concat(mixin.excluded);
      }
      for (k in mixin) {
        v = mixin[k];
        if (__indexOf.call(excl, k) < 0) {
          this[k] = v;
        }
      }
      if (typeof mixin.extended === "function") {
        mixin.extended(this);
      }
    }
    return this;
  };

  Function.prototype.concern = function() {
    var mixins;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this.include.apply(this, mixins);
    return this.extend.apply(this, mixins);
  };

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

  mixins.Cloneable = function() {
    var ConcreteCloneable, properties;
    properties = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return ConcreteCloneable = (function() {
      function ConcreteCloneable() {}

      if (properties.length === 0) {
        ConcreteCloneable.included = function(klass) {
          return klass.prototype.clone = function() {
            return new klass(this);
          };
        };
      } else {
        ConcreteCloneable.included = function(klass) {
          return klass.prototype.clone = function() {
            var _this = this;
            return build(klass, properties.map(function(p) {
              return _this[p];
            }));
          };
        };
      }

      return ConcreteCloneable;

    })();
  };

  mixins.Cloneable._name = 'Cloneable';

  mixins.Equatable = function() {
    var ConcreteEquatable, properties;
    properties = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return ConcreteEquatable = (function() {
      function ConcreteEquatable() {}

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

    })();
  };

  mixins.Equatable._name = 'Equatable';

  mixins.Formattable = function() {
    var ConcretFormattable, classname, properties;
    classname = arguments[0], properties = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return ConcretFormattable = (function() {
      function ConcretFormattable() {}

      if (properties.length === 0) {
        ConcretFormattable.prototype.toString = function() {
          return "[" + classname + "]";
        };
      } else {
        ConcretFormattable.prototype.toString = function() {
          var formattedProperties, p;
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
        };
      }

      ConcretFormattable.prototype.classname = function() {
        return classname;
      };

      return ConcretFormattable;

    })();
  };

  mixins.Formattable._name = 'Formattable';

  mixins.Memoizable = (function() {
    function Memoizable() {}

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

  })();

  mixins.Parameterizable = function(method, parameters, allowPartial) {
    var ConcreteParameterizable;
    if (allowPartial == null) {
      allowPartial = false;
    }
    return ConcreteParameterizable = (function() {
      function ConcreteParameterizable() {}

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

    })();
  };

  mixins.Parameterizable._name = 'Parameterizable';

  mixins.Poolable = (function() {
    function Poolable() {}

    Poolable.extended = function(klass) {
      klass.usedInstances = [];
      return klass.unusedInstances = [];
    };

    Poolable.get = function(options) {
      var instance;
      if (options == null) {
        options = {};
      }
      if (this.unusedInstances.length > 0) {
        instance = this.unusedInstances.shift();
      } else {
        instance = new this;
      }
      this.usedInstances.push(instance);
      instance.init(options);
      return instance;
    };

    Poolable.release = function(instance) {
      var index;
      if (__indexOf.call(this.usedInstances, instance) < 0) {
        throw new Error("Can't release an unused instance");
      }
      index = this.usedInstances.indexOf(instance);
      this.usedInstances.splice(index, 1);
      return this.unusedInstances.push(instance);
    };

    Poolable.prototype.init = function(options) {
      var k, v, _results;
      if (options == null) {
        options = {};
      }
      _results = [];
      for (k in options) {
        v = options[k];
        _results.push(this[k] = v);
      }
      return _results;
    };

    Poolable.prototype.dispose = function() {
      return this.constructor.release(this);
    };

    return Poolable;

  })();

  mixins.Sourcable = function() {
    var ConcreteSourcable, name, signature;
    name = arguments[0], signature = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return ConcreteSourcable = (function() {
      var sourceFor;

      function ConcreteSourcable() {}

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

    })();
  };

  mixins.Sourcable._name = 'Sourcable';

}).call(this);

/*
//@ sourceMappingURL=mixins.js.map
*/