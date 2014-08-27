CSON = require 'season'
temp = require 'temp'

ScopeWrapper = require '../lib/scope-wrapper'
SharedApi = require './shared/api-spec'

describe 'ScopeWrapper', ->
  SharedApi.examples ->
    configPath = temp.path('scope-wrapper')
    configWrapper = new ScopeWrapper(atom.config, configPath)
    [configWrapper, configPath]

  describe 'rooted at a different path', ->
    [configPath, configWrapper] = []

    beforeEach ->
      atom.config.defaultSettings =
        foo:
          bar: 9
          baz: 9

      atom.config.set('foo.bar', 3)

      configPath = temp.path('scope-wrapper')
      CSON.writeFileSync configPath,
        source:
          foo:
            foo:
              bar: 13
      configWrapper = new ScopeWrapper(atom.config, configPath, 'source.foo')

    it 'overrides the wrapped values with the rooted ones', ->
      expect(configWrapper.get('foo.bar')).toBe(13)
