(function() {
  var Mixin;

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

  module.exports = Mixin;

}).call(this);
