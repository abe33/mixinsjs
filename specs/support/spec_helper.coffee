
if typeof module is 'undefined'
  mixins = window.mixins
else
  global.mixins = mixins = require '../../lib/mixins'
