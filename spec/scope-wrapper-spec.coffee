temp = require 'temp'

ScopeWrapper = require '../lib/scope-wrapper'

describe 'ScopeWrapper', ->
  scopeWrapper = null
  configPath = null

  beforeEach ->
    atom.config.defaultSettings =
      foo:
        bar: 9
        baz: 9

    configPath = temp.path('layered-config')

    atom.config.set('foo.bar', 3)
    scopeWrapper = new ScopeWrapper(atom.config, configPath, 'source.ruby')

  it 'wraps the passed configuration object', ->
    expect(scopeWrapper.wrappedConfig).toBe(atom.config)
