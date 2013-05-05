eng = require "./engine"

engine = new eng.Engine

engine.addSystem "diagnostics",
    components: ["test"]
    addEntities: (entities) ->
        console.log "Adding"
        console.log entities
    removeEntities: (entities) ->
        console.log "Removing"
        console.log entities
    tick: (dt) ->
        console.log "tick"

engine.createEntity()
engine.createEntity()

engine.gameLoop(0.1)
engine.removeOneEntity()
engine.gameLoop(0.1)
engine.removeOneEntity()
engine.gameLoop(0.1)
