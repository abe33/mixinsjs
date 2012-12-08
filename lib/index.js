(function() {

  module.exports = {
    Mixin: require('./mixinsjs/mixin'),
    Module: require('./mixinsjs/module'),
    include: require('./mixinsjs/include'),
    Cloneable: require('./mixinsjs/cloneable'),
    Sourcable: require('./mixinsjs/sourcable'),
    Equatable: require('./mixinsjs/equatable'),
    Formattable: require('./mixinsjs/formattable'),
    Memoizable: require('./mixinsjs/memoizable'),
    Parameterizable: require('./mixinsjs/parameterizable')
  };

}).call(this);
