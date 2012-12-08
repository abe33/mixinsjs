(function() {
  var Equatable, Mixin,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mixin = require('./mixin');

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

  module.exports = Equatable;

}).call(this);
