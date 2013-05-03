entitymanager = require "../src/entitymanager"

describe "Entity management", ->
    em = new entitymanager.EntityManager

    beforeEach ->
        em = new entitymanager.EntityManager

    describe "#createEntity", ->
        entity1 = em.createEntity false
        entity2 = em.createEntity false
        it "should be truthy", ->
            entity1.should.not.be.null

        it "shouldn't be repeated", ->
            entity1.should.not.equal entity2

    describe "#removeEntity", ->
        entity = em.createEntity true
        it "should remove the entity", ->
            em.removeEntity entity, true
            em.entities.should.not.contain entity

    describe "#setComponent", ->
        entity = em.createEntity false
        it "should create a component category", ->
            em.setComponent entity, "test"
                name: "Hello"

    describe "#removeComponent", ->
        entity = em.createEntity false
        it "should create a component category", ->
            em.setComponent entity, "test"
                name: "Hello"

    describe "#subscribe", ->
        entity = em.createEntity false
        it "should create a component category", ->
            em.setComponent entity, "test"
                name: "Hello"
