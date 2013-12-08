
# The `Aliasable` mixin provides the `alias` method in extended classes.
#
#     class Dummy
#       @extend mixins.Aliasable
#
#       someMethod: ->
#       @alias 'someMethod', 'someMethodAlias'
class mixins.Aliasable
  ##### Aliasable.alias
  #
  # Creates aliases for the given `source` property of tthe current
  # class prototype. Any number of alias can be passed at once.
  @alias: (source, aliases...) ->
    desc = Object.getPropertyDescriptor @prototype, source

    if desc?
      Object.defineProperty @prototype, alias, desc for alias in aliases
    else
      if @prototype[ source ]?
        @prototype[ alias ] = @prototype[ source ] for alias in aliases
