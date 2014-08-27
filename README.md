# Layered Configuration

A package for exploring the concept of a layered configuration approach for Atom.

*Note:* I haven't spent a lot of time thinking about the names of the classes in this package because this is just a proof-of-concept. I fully expect that if this functionality ends up being integrated into Atom proper that the class names will change.

## General Concept

Configuration values are stored in generic objects which are retrieved from a configuration store, typically a file in disk storage. Each configuration object is responsible for updating the in-memory settings when its backing store is updated.

The layered effect is achieved by a configuration object wrapping another configuration object. This can be done multiple times to create a chain of configuration stores. The outer object's values take precedence over the inner object's values, much as the user's configuration values take precedence over the default values in the standard configuration class.

## API

This is the basic API that all conforming configuration classes will use.

### `get(keyPath)`

Retrieves the value at the given key path, with the outer object's values taking precedence over the inner object's values. If the value at the given key path is an object, the objects are merged.

### `getConfigPaths()`

Gets the list of configuration store paths from outer to inner objects.

### `getDefault(keyPath)`

Gets the default value from the innermost configuration object.

### `getInt(keyPath)`

Gets the value at the given key path as an integer.

### `getPositiveInt(keyPath, defaultValue=0)`

Gets the value at the given key path as a positive integer.

### `getSettings()`

Gets the entire settings object, merged by priority.

### `isDefault(keyPath)`

Returns a flag indicating whether the given path is using the default value.

### `observe(keyPath, options, callback)`

Begins watching a given key path for changes across all configuration stores.

### `pushAtKeyPath(keyPath, value)`

Push the value onto the end of the array at the path.

### `removeAtKeyPath(keyPath, value)`

Removes the value from the array at the path.

### `restoreDefault(keyPath)`

Restores the value to its default value. **Note:** If one reads immediately after calling this method, one may still get a value that does not equal the default because the outer configuration objects still override the default.

### `set(keyPath, value)`

Sets the value at the given key path but *only on the inner object*. This is done because it is most likely the intention of the calling code to set the value on the user's configuration, which is going to be the innermost object in any chain of layered configurations.

### `toggle(keyPath)`

Toggles the value at the key path.

### `unobserve(keyPath)`

Cancels all observation of the given key path across all configuration stores.

### `unshiftAtKeyPath(keyPath, value)`

Adds the value at the beginning of the array stored at the path.
