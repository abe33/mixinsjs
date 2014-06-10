expose = (obj) -> window[key] = obj[key] for key of obj

# attach jasmine to window
expose require('./jasmine/jasmine.js')

# attach tap reporter to jasmine
# this is essential for running tests on ci.testling.com
require './jasmine/jasmine-tap.js'

# expose helpers
expose require('./support/spec_helper')

# insert test files here
require('./units/function.spec.coffee')

startJasmine = ->
  jasmine.getEnv().addReporter new jasmine.TapReporter()
  jasmine.getEnv().execute()

currentWindowOnload = window.onload

window.onload = ->
  currentWindowOnload() if currentWindowOnload?
  setTimeout startJasmine, 1
