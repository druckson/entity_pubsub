array_remove = (a, e) ->
    a[t..t] = [] if (t = a.indexOf(e)) > -1
#Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

class EntityManager
    constructor: () ->
        @nextEntity = 0
        @entities = []
        @components = {}

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
    removeEntity: (entity) ->
        if entity in @entities
            array_remove @entities, entity

    # Set new data for the specified component on the entity
    # Adds the data to either the enter or update queue
    setComponent: (entity, component, data) ->
        if not (component in @components)
            @components[component] = {}
        if not (entity in @components[component])
            @components[component][entity] = data

    # Remove the component from the entity
    # Adds the data to the exit queue
    removeComponent: (entity, component) ->
        if not component in @components
            @components[component] = {}
        if entity of @components[component]
            delete @components[component][entity]

    #Query functions
    getComponentForEntity: (entity, component) ->
        return @components[component][entity]

    getComponentsForEntity: (entity) ->
        data = {}
        for componentID, component of @components
            if entity of component
                data[componentID] = component[entity]
        return data

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

    # Subscription process
    subscribe: (subscriberID, components, enterHandler, exitHandler, notify) ->
        for component in components
            if not (component in @subscriberComponents)
                @subscriberComponents[component] = []
            @subscriberComponents[component].push subscriberID

        subscriber =
            components: components
            entities: []
            enterHandler: enterHandler
            exitHandler: exitHandler

        @subscribers[subscriberID] = subscriber
        if notify then this.notifySubscriber subscriber

    notifySubscriber: (subscriber) ->
        queueEnterEntities = []
        queueExitEntities = []
        for entity in @entities
            if (this._subscriberNeedsEntity subscriber, entity) and not (entity in subscriber.entities)
                subscriber.entities.push entity
                queueEnterEntities.push entity

            if not (this._subscriberNeedsEntity subscriber, entity) and (entity in subscriber.entities)
                array_remove subscriber.entities, entity
                queueExitEntities.push entity
        subscriber.enterHandler queueEnterEntities
        subscriber.exitHandler queueExitEntities

    # Synchronize entity state with all subscribers
    notify: () ->
        for subscriberID, subscriber of @subscribers
            this.notifySubscriber subscriber

    # Helper functions
    _subscriberNeedsEntity: (subscriber, entity) ->
        for component in subscriber.components
            if not (entity of @components[component])
                return false
        return true


exports.EntityManager = EntityManager
