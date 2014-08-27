CSON = require 'season'
fs = require 'fs-plus'
_ = require 'underscore-plus'

ConfigWrapper = require './config-wrapper'

module.exports =
class ScopeWrapper extends ConfigWrapper
  constructor: (@wrappedConfig, @configPath, @root) ->
    super(@wrappedConfig, @configPath)

  get: (keyPath) ->
    if fs.existsSync(@configPath)
      @settings = CSON.readFileSync(@configPath)

    value = if @root
              _.valueForKeyPath(@settings, [@root, keyPath].join('.'))
            else
              _.valueForKeyPath(@settings, keyPath)
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
