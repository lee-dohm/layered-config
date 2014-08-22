module.exports =
class ScopeWrapper
  constructor: (@wrappedConfig, @configPath, @root) ->
    @settings = {}
