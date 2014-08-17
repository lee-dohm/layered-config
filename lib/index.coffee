LayeredConfig = null

module.export =
  activate: ->
    @originalConfig = atom.config

    LayeredConfig ?= require './layered-config'
    atom.config = new LayeredConfig(atom.config)

  deactivate: ->
    atom.config = @originalConfig
    LayeredConfig = null
