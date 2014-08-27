temp = require 'temp'

ConfigWrapper = require '../lib/config-wrapper'
SharedApi = require './shared/api-spec'

describe 'ConfigWrapper', ->
  SharedApi.examples ->
    configPath = temp.path('config-wrapper')
    configWrapper = new ConfigWrapper(atom.config, configPath)
    [configWrapper, configPath]
