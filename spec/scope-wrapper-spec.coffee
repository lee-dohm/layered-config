temp = require 'temp'

ScopeWrapper = require '../lib/scope-wrapper'
SharedApi = require './shared/api-spec'

describe 'ScopeWrapper', ->
  SharedApi.examples ->
    configPath = temp.path('scope-wrapper')
    configWrapper = new ScopeWrapper(atom.config, configPath)
    [configWrapper, configPath]
