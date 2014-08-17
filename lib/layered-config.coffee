CSON = require 'season'
fs = require 'fs-plus'
_ = require 'underscore-plus'

module.exports =
class LayeredConfig
  constructor: (@wrappedConfig, @configPath) ->
    @settings = {}

  # Public: Gets the value at the given `keyPath`.
  #
  # keyPath - Path {String} from which to retrieve the configuration value.
  #
  # Returns: Value stored at the given path.
  get: (keyPath) ->
    if fs.existsSync(@configPath)
      @settings = CSON.readFileSync(@configPath)

    value = _.valueForKeyPath(@settings, keyPath)
    wrappedValue = @wrappedConfig.get(keyPath)

    if value?
      value = _.deepClone(value)
      valueIsObject = _.isObject(value) and not _.isArray(value)
      wrappedValueIsObject = _.isObject(wrappedValue) and not _.isArray(wrappedValue)
      if valueIsObject and wrappedValueIsObject
        _.defaults(value, wrappedValue)
    else
      value = _.deepClone(wrappedValue)

    value

  # Public: Gets the list of paths for configuration files from highest to lowest priority.
  #
  # Returns an {Array} of paths for the represented configuration files.
  getConfigPaths: ->
    path = @wrappedConfig.getConfigPaths?() ? @wrappedConfig.getUserConfigPath?()
    [@configPath].concat(path)

  # Public: Sets the value at the given path in the wrapped configuration file.
  #
  # keyPath - Path {String} at which to set the value.
  # value - Value to set.
  set: (keyPath, value) ->
    @wrappedConfig.set(keyPath, value)
