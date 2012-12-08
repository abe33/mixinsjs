(function() {
  var Formattable, Mixin,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mixin = require('./mixin');

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

  module.exports = Formattable;

}).call(this);
