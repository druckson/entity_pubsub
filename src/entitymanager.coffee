Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

class EntityManager
    constructor: () ->
        @nextEntity = 0
        @entities = []
        @components = {}

        # Buffers for entity modification
        @queueRemoveEntity = []
        @queueCreateComponent = []
        @queueRemoveComponent = []
        @queueEnterEntity = {}
        @queueExitEntity = {}

        # Subscription data
        @subscribers = []
        @subscriberComponents = {}

    # Create and return a new entity ID
    # For now, entity IDs are integers counting from 0
    createEntity: ->
        new_entity = @nextEntity++
        @entities.push new_entity
        return new_entity

    # Add an entity to the remove queue
    removeEntity: (entity, flush) ->
        if entity in @entities
            @queueRemoveEntity.push entity
        if flush then this.flush()

    # Set new data for the specified component on the entity
    # Adds the data to either the enter or update queue
    setComponent: (entity, component, data) ->
        if not (component in @components)
            @components[component] = {}
        if not (entity in @components[component])
            @queueCreateComponent.push
                entity: entity
                component: component
                data: data

    # Remove the component from the entity
    # Adds the data to the exit queue
    removeComponent: (entity, component) ->
        if not component in @components
            @components[component] = {}
        if entity in @components[component]
            @queueRemoveComponent.push
                entity: entity
                component: component

    #Query functions
    getComponentsForEntity: (entity) ->
        data = {}
        for component, componentID in @components
            if entity in component
                data[componentID] = component[entity]

    getEntitiesWithComponent: (component) ->
        entities = []
        for entity in @entities
            if entity in @components[component]
                entities.push entity
        return entities

    getEntitiesWithComponents: (components) ->
        entities = []
        for entity in @entities
            present = true
            for component in components
                if entity in @components[component]
                    present = false
            if present
                entities.push entity
        return entities

    # Subscription functions
    subscribe: (subscriberID, components, enterHandler, exitHandler) ->
        for component in components
            @subscriberComponents[component].push subscriber

        @queueEnterEntity[subscriberID] = []
        @queueExitEntity[subscriberID] = []
        @subscribers[subscriberID] =
            components: components
            enterHandler: enterHandler
            exitHandler: exitHandler

    flush: () ->
        # Run create operations
        while @queueCreateComponent.length > 0
            c = @queueCreateComponent.shift()
            console.log "creating component" + c
            @components[c.component][c.entity] = c.data

        # Fill synchronization queues for each subscriber
        for subscriber, subscriberID in @subscribers
            for createComponent in @queueCreateComponent
                if this._subscriberEnterComponent createComponent.entity, createComponent.component
                    @queueEnterEntity[subscriberID].push(createComponent.entity)

            for removeComponent in @queueRemoveComponent
                if this._subscriberExitComponent removeComponent.entity, removeComponent.component
                    @queueExitEntity[subscriberID].push(removeComponent.entity)

            for entity in @queueRemoveEntity
                if this._subscrierNeedsEntity(subscriber, entity)
                    @queueExitEntity[subscriberID].push(entity)

        # Trigger synchronization events for subscribers
        for subscriber, subscriberID in @subscribers
            subscriber.enterHandler(@queueEnterEntity[subscriberID])
            subscriber.exitHandler(@queueExitEntity[subscriberID])

        # Run removal operations
        while @queueRemoveComponent.length > 0
            c = @queueRemoveComponent.shift()
            console.log "removing component" + c
            @components[c.component].remove c.entity
        while @queueRemoveEntity.length > 0
            entity = @queueRemoveEntity.shift()
            console.log "removing entity " + entity
            console.log @entities
            @entities.remove entity
            console.log @entities

    # Helper functions
    _subscriberNeedsEntity: (subscriber, entity) ->
        for c, component in subscriber.components
            if not entity in @components[c]
                return false
        return true

    _subscriberEnterComponent: (subscriber, newComponent) ->
        needEntityBefore = true
        needEntityAfter = true
        for c, component in subscriber.components
            if not entity in @components[c]
                needEntityBefore = false
                if not component = newComponent
                    needEntityAfter = false
        return needEntityAfter && not needEntityBefore

    _subscriberExitComponent: (subscriber, newComponent) ->
        needEntityBefore = true
        needEntityAfter = true
        for c, component in subscriber.components
            if not entity in @components[c]
                needEntityBefore = false
                needEntityAfter = false
            if component = newComponent
                needEntityAfter = false
        return needEntityAfter && not needEntityBefore


exports.EntityManager = EntityManager
