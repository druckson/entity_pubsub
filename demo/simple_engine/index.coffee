eng = require "./engine"

engine = new eng.Engine

class Diagnostics
    constructor: () ->
        @components = ["test"]
    init: (engine) ->
        @engine = engine
    addEntities: (entities) ->
        console.log "Adding"
        console.log entities
    removeEntities: (entities) ->
        console.log "Removing"
        console.log entities
    tick: (dt) ->
        console.log "tick"

engine.addSystem "diagnostics", new Diagnostics

engine.createEntity()
engine.createEntity()
engine.createEntity()

engine.gameLoop(0.1)
setInterval () ->
    engine.removeOneEntity()
, 100
