class EntityManager
    constructor: () ->
        @nextEntity = 0
        @entities = []
        @components = {}

        # Buffers for component modification
        @enter_components = []
        @update_components = []
        @exit_components = []

        # Subscription data
        @subscribers = []
        @subscriberComponents = {};

    # Create and return a new entity ID
    # For now, entity IDs are integers counting from 0
    createEntity: () ->
        new_entity = @nextEntity++
        @entities.push new_entity
        new_entity

    # Set new data for the specified component on the entity
    # Adds the data to either the enter or update queue
    setComponent: (entity, component, data) ->
        if not component in @components
            @components[component] = []

        message =
            entity: entity
            component: component
            data: data

        if not entity in @components[component]
            @enter_components.push message

        @update_components.push message

    # Remove the component from the entity
    # Adds the data to the exit queue
    removeComponent: (entity, component) ->

    subscriberNeedsEntity: (subscriber, entity) ->
        for c, component in subscriber.components
            if not entity in @components[c]
                return false
        return true

    subscribe: (subscriber, components, enterHandler, updateHandler, exitHandler) ->
        for component in components
            @subscriberComponents[component].push subscriber

        @subscribers[subscriber] =
            components: components
            enterHandler: enterHandler
            updateHandler: updateHandler
            exitHandler: exitHandler
    _flushEnter: (subscriber) ->
        console.log enter_components
    _flushUpdate: (subscriber) ->
        console.log update_components
    _flushExit: (subscriber) ->
        console.log exit_components

    flush: () ->
        for subscriber in @subscribers
            this._flushEnter  subscriber
            this._flushUpdate subscriber
            this._flushExit   subscriber

exports.EntityManager = EntityManager
