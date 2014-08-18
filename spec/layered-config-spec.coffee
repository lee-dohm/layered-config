CSON = require 'season'
temp = require 'temp'

LayeredConfig = require '../lib/layered-config'

describe "LayeredConfig", ->
  layeredConfig = null
  configPath = null

  beforeEach ->
    atom.config.defaultSettings =
      foo:
        bar: 9
        baz: 9

    configPath = temp.path('layered-config')

    atom.config.set('foo.bar', 3)
    layeredConfig = new LayeredConfig(atom.config, configPath)

  it 'wraps the passed configuration object', ->
    expect(layeredConfig.wrappedConfig).toBe(atom.config)

  describe '.get()', ->
    it 'returns undefined if nothing has a setting for that value', ->
      expect(layeredConfig.get('foozle.bamboozle')).not.toBeDefined()

    it 'gets the value from the wrapped configuration object', ->
      expect(layeredConfig.get('foo.bar')).toBe(3)

    it 'gets the value from the config file if the value is overridden', ->
      CSON.writeFileSync(configPath, foo: { bar: 5 })

      expect(layeredConfig.get('foo.bar')).toBe(5)

    it 'gets the merged contents if the requested key is an object', ->
      atom.config.set('foo', a: 3, b: 3, c: 9)
      CSON.writeFileSync(configPath, foo: { a: 3, b: 5 })

      expect(layeredConfig.get('foo')).toEqual(a: 3, b: 5, c: 9, bar: 9, baz: 9)

  describe '.getDefault()', ->
    it 'gets the value from the wrapped configuration object', ->
      expect(layeredConfig.getDefault('foo.bar')).toEqual(9)

  describe '.getInt()', ->
    it 'returns the value from the wrapped configuration as an integer', ->
      expect(layeredConfig.getInt('foo.bar')).toEqual(3)

  describe '.getPositiveInt()', ->
    it 'returns the value from the wrapped configuration as a positive integer', ->
      expect(layeredConfig.getPositiveInt('foo.bar')).toEqual(3)

  describe '.getSettings()', ->
    it 'returns the merged set of settings', ->
      atom.config.set('foo', a: 3, b: 3, c: 9)
      CSON.writeFileSync(configPath, foo: { a: 3, b: 5 })

      expect(layeredConfig.getSettings().foo).toEqual(a: 3, b: 5, c: 9, bar: 9, baz: 9)

  describe '.isDefault()', ->
    it 'returns true when the value is the default', ->
      expect(layeredConfig.isDefault('foo.baz')).toBeTruthy()

    it 'returns false when the value is not the default', ->
      expect(layeredConfig.isDefault('foo.bar')).toBeFalsy()

  describe '.set()', ->
    it 'sets the value to the wrapped configuration object', ->
      layeredConfig.set('foo.bar', 5)

      expect(atom.config.get('foo.bar')).toBe(5)

    it 'does not change the contents of the configuration file', ->
      CSON.writeFileSync(configPath, foo: { bar: 3 })
      layeredConfig.set('foo.bar', 5)

      expect(CSON.readFileSync(configPath)).toEqual(foo: { bar: 3 })

  describe '.getConfigPaths()', ->
    it 'returns the array of paths in priority order', ->
      expect(layeredConfig.getConfigPaths()).toEqual([configPath, atom.config.getUserConfigPath()])
