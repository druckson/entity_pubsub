entitymanager = require "../../src/entitymanager"

class Engine
    constructor: () ->
        @em = new entitymanager.EntityManager
        @systems = {}
    createEntity: () ->
        entity = @em.createEntity()
        @em.setComponent entity, "test",
            foo: "bar"
    removeOneEntity: () ->
        @em.removeEntity @em.entities[0]
    addSystem: (systemName, system) ->
        @systems[systemName] = system
        @em.subscribe systemName, system.components,
                      system.addEntities, system.removeEntities
    gameLoop: (dt) ->
        self = this
        for name, system of @systems
            system.init this
        setInterval () ->
            self.em.notify()
        , 500
exports.Engine = Engine
