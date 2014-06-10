{spawn} = require 'child_process'
{print} = require 'util'
Q = require 'q'

run = (command) ->
  defer = Q.defer()
  [command, args...] = command.split(/\s+/g)
  exe = spawn command, args
  exe.stdout.on 'data', (data) -> print data
  exe.stderr.on 'data', (data) -> print data
  exe.on 'exit', (status) ->
    if status is 0 then defer.resolve(status) else defer.reject(status)
  defer.promise

module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        options:
          join: true
          sourceMap: true

        files:
          'lib/mixins.js': [
            'src/index.coffee'
            'src/object.coffee'
            'src/function.coffee'
            'src/inheritance.coffee'
            'src/mixinsjs/mixin.coffee'
            'src/mixinsjs/*.coffee'
          ]

          'lib/mixins.spec.js': [
            'specs/support/spec_helper.coffee'
            'specs/units/**/*.coffee'
          ]

    uglify:
      all:
        files:
          'lib/mixins.min.js': ['lib/mixins.js']

    watch:
      scripts:
        files: ['src/**/*.coffee', 'specs/**/*.coffee']
        tasks: ['coffee', 'uglify', 'test']

      config:
        files: ['Gruntfile.coffee']
        options:
          reload: true

    growl:
      jasmine_success:
        title: 'Jasmine Tests'
        message: 'All test passed'

      jasmine_failure:
        title: 'Jasmine Tests'
        message: 'Some tests failed'

  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-growl')

  grunt.registerTask 'test', 'Run npm tests', ->
    done = @async()
    run('npm test')
    .then ->
      grunt.task.run 'growl:jasmine_success'
      done true
    .fail ->
      console.log 'in fail'
      grunt.task.run 'growl:jasmine_failure'
      done false


  grunt.registerTask('default', ['test'])
