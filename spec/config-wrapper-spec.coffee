CSON = require 'season'
temp = require 'temp'

ConfigWrapper = require '../lib/config-wrapper'

describe "ConfigWrapper", ->
  configWrapper = null
  configPath = null

  beforeEach ->
    atom.config.defaultSettings =
      foo:
        bar: 9
        baz: 9

    configPath = temp.path('layered-config')

    atom.config.set('foo.bar', 3)
    configWrapper = new ConfigWrapper(atom.config, configPath)

  it 'wraps the passed configuration object', ->
    expect(configWrapper.wrappedConfig).toBe(atom.config)

  describe '.get()', ->
    it 'returns undefined if nothing has a setting for that value', ->
      expect(configWrapper.get('foozle.bamboozle')).not.toBeDefined()

    it 'gets the value from the wrapped configuration object', ->
      expect(configWrapper.get('foo.bar')).toBe(3)

    it 'gets the value from the config file if the value is overridden', ->
      CSON.writeFileSync(configPath, foo: { bar: 5 })

      expect(configWrapper.get('foo.bar')).toBe(5)

    it 'gets the merged contents if the requested key is an object', ->
      atom.config.set('foo', a: 3, b: 3, c: 9)
      CSON.writeFileSync(configPath, foo: { a: 3, b: 5 })

      expect(configWrapper.get('foo')).toEqual(a: 3, b: 5, c: 9, bar: 9, baz: 9)

  describe '.getDefault()', ->
    it 'gets the value from the wrapped configuration object', ->
      expect(configWrapper.getDefault('foo.bar')).toEqual(9)

  describe '.getInt()', ->
    it 'returns the value from the wrapped configuration as an integer', ->
      expect(configWrapper.getInt('foo.bar')).toEqual(3)

  describe '.getPositiveInt()', ->
    it 'returns the value from the wrapped configuration as a positive integer', ->
      expect(configWrapper.getPositiveInt('foo.bar')).toEqual(3)

  describe '.getSettings()', ->
    it 'returns the merged set of settings', ->
      atom.config.set('foo', a: 3, b: 3, c: 9)
      CSON.writeFileSync(configPath, foo: { a: 3, b: 5 })

      expect(configWrapper.getSettings().foo).toEqual(a: 3, b: 5, c: 9, bar: 9, baz: 9)

  describe '.isDefault()', ->
    it 'returns true when the value is the default', ->
      expect(configWrapper.isDefault('foo.baz')).toBeTruthy()

    it 'returns false when the value is not the default', ->
      expect(configWrapper.isDefault('foo.bar')).toBeFalsy()

  describe '.set()', ->
    it 'sets the value to the wrapped configuration object', ->
      configWrapper.set('foo.bar', 5)

      expect(atom.config.get('foo.bar')).toBe(5)

    it 'does not change the contents of the configuration file', ->
      CSON.writeFileSync(configPath, foo: { bar: 3 })
      configWrapper.set('foo.bar', 5)

      expect(CSON.readFileSync(configPath)).toEqual(foo: { bar: 3 })

  describe '.getConfigPaths()', ->
    it 'returns the array of paths in priority order', ->
      expect(configWrapper.getConfigPaths()).toEqual([configPath, atom.config.getUserConfigPath()])
