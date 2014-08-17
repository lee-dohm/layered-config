CSON = require 'season'
fs = require 'fs-plus'
_ = require 'underscore-plus'

module.exports =
class LayeredConfig
  constructor: (@wrappedConfig, @configPath) ->
    @settings = {}

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

  set: (keyPath, value) ->
    @wrappedConfig.set(keyPath, value)
