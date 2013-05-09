array_remove = (a, e) ->
    a[t..t] = [] if (t = a.indexOf(e)) > -1

array_contains = (a, e) ->
    for element in a
        return true if element is e
    return false

#Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

class EntityManager
    constructor: () ->
        @nextEntity = 100
        @entities = []
        @components = {}
        @subscribers = []

    # Create and return a new entity ID
    # For now, entity IDs are integers counting from 0
    createEntity: ->
        new_entity = @nextEntity++
        @entities.push new_entity
        return new_entity

    addEntity: (entityID) ->
        @nextEntity = Math.max @nextEntity, entityID+1
        @entities.push entityID
        return entityID

    # Add an entity to the remove queue
    removeEntity: (entity) ->
        if entity in @entities
            array_remove @entities, entity

    # Set new data for the specified component on the entity
    # Adds the data to either the enter or update queue
    setComponent: (entity, component, data) ->
        if not (component of @components)
            @components[component] = {}
        if not (entity of @components[component])
            @components[component][entity] = data

    setComponents: (entity, data) ->
        for key, value of data
            @setComponent entity, key, value

    # Remove the component from the entity
    # Adds the data to the exit queue
    removeComponent: (entity, component) ->
        if not (component of @components)
            @components[component] = {}
        if (entity of @components[component])
            delete @components[component][entity]

    #Query functions
    getComponentForEntity: (entity, components) ->
        return @components[component][entity]

    getComponentsForEntity: (entity, components) ->
        data = {}
        for componentID, component of @components
            if components
                if entity of component and componentID in components
                    data[componentID] = component[entity]
            else
                if entity of component
                    data[componentID] = component[entity]
        return data

    getComponentsForEntities: (entities, components) ->
        data = []
        for entity in entities
            data.push @getComponentsForEntity entity, components
        return data

    getEntitiesWithComponent: (component) ->
        entities = []
        for entity in @entities
            if component of @components and entity in @components[component]
                entities.push entity
        return entities

    getEntitiesWithComponents: (components) ->
        entities = []
        for entity in @entities
            present = true
            for component in components
                if component of @components and entity in @components[component]
                    present = false
            if present
                entities.push entity
        return entities

    # Subscription process
    subscribe: (subscriberID, components, enterHandler, exitHandler, notify) ->
        subscriber =
            components: components
            entities: []
            enterHandler: enterHandler
            exitHandler: exitHandler

        @subscribers[subscriberID] = subscriber
        if notify then this.notifySubscriber subscriber

    # Synchronize state with a single subscriber
    notifySubscriber: (subscriber) ->
        queueEnterEntities = []
        queueExitEntities = []
        for id, entity of @entities
            if (this._subscriberNeedsEntity subscriber, entity) and not (entity in subscriber.entities)
                queueEnterEntities.push entity
                subscriber.entities.push entity

        for id, entity of subscriber.entities
            if not (this._subscriberNeedsEntity subscriber, entity)
                queueExitEntities.push entity
                array_remove subscriber.entities, entity

        if queueEnterEntities.length > 0
            subscriber.enterHandler queueEnterEntities
        if queueExitEntities.length > 0
            subscriber.exitHandler queueExitEntities

    # Synchronize entity state with all subscribers
    notify: () ->
        for subscriberID, subscriber of @subscribers
            this.notifySubscriber subscriber

    # Helper functions
    _subscriberNeedsEntity: (subscriber, entity) ->
        for component in subscriber.components
            if not (array_contains @entities, entity) or not (entity of @components[component])
                return false
        return true


module.exports = EntityManager
