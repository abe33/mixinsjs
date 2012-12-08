(function() {
  var include,
    __slice = [].slice;

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

  module.exports = include;

}).call(this);
