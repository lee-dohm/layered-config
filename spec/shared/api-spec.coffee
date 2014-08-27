CSON = require 'season'

# Shared examples implementation from:
# http://pivotallabs.com/drying-up-jasmine-specs-with-shared-behavior/

module.exports =
  examples: (init) ->
    describe 'conforms to the configuration API', ->
      [configWrapper, configPath] = []

      beforeEach ->
        atom.config.defaultSettings =
          foo:
            bar: 9
            baz: 9

        atom.config.set('foo.bar', 3)
        [configWrapper, configPath] = init()

      it 'wraps the passed configuration object', ->
        expect(configWrapper.wrappedConfig).toBe(atom.config)

      it 'remembers the passed configuration path', ->
        expect(configWrapper.configPath).toBe(configPath)

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

      describe '.getConfigPaths()', ->
        it 'returns the array of paths in priority order', ->
          expect(configWrapper.getConfigPaths()).toEqual([configPath, atom.config.getUserConfigPath()])

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

      describe '.pushAtKeyPath()', ->
        it 'sets the value on the wrapped configuration object', ->
          atom.config.set('foo', a: [1, 3, 5])
          configWrapper.pushAtKeyPath('foo.a', 7)

          expect(atom.config.get('foo.a')).toEqual([1, 3, 5, 7])

      describe '.removeAtKeyPath()', ->
        it 'sets the value on the wrapped configuration object', ->
          atom.config.set('foo', a: [1, 3, 5])
          configWrapper.removeAtKeyPath('foo.a', 3)

          expect(atom.config.get('foo.a')).toEqual([1, 5])

      describe '.restoreDefault()', ->
        it 'restores the default value on the wrapped configuration object', ->
          configWrapper.restoreDefault('foo.bar')

          expect(configWrapper.get('foo.bar')).toBe(9)

      describe '.set()', ->
        it 'sets the value to the wrapped configuration object', ->
          configWrapper.set('foo.bar', 5)

          expect(atom.config.get('foo.bar')).toBe(5)

        it 'does not change the contents of the configuration file', ->
          CSON.writeFileSync(configPath, foo: { bar: 3 })
          configWrapper.set('foo.bar', 5)

          expect(CSON.readFileSync(configPath)).toEqual(foo: { bar: 3 })

      describe '.toggle()', ->
        it 'sets the value on the wrapped configuration object', ->
          configWrapper.toggle('foo.boolean')

          expect(atom.config.get('foo.boolean')).toBeTruthy()

      describe '.unshiftAtKeyPath()', ->
        it 'sets the value on the wrapped configuration object', ->
          atom.config.set('foo', a: [1, 3, 5])
          configWrapper.unshiftAtKeyPath('foo.a', 11)

          expect(atom.config.get('foo.a')).toEqual([11, 1, 3, 5])
