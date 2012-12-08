(function() {
  var Module,
    __slice = [].slice;

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

  module.exports = Module;

}).call(this);
