(function() {
  var Memoizable, Mixin,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mixin = require('./mixin');

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

  module.exports = Memoizable;

}).call(this);
