# Public: The `Activable` mixin provides the basic interface for an activable
# widget. You can hook your own activation/deactivation routines by overriding
# the `activated` and `deactivated` methods.
#
# ```coffeescript
# class Dummy
#   @include mixins.Activable
#
#   activated: ->
#     # ...
#
#   deactivated: ->
#     # ...
# ```
#
# `Activable` instances are deactivated at creation.
class mixins.Activable
  active: false

  # Public: Activates the instance.
  activate: ->
    return if @active
    @active = true
    @activated?()

  # Public: Deactivates the instance.
  deactivate: ->
    return unless @active
    @active = false
    @deactivated?()
