EntityManager = require "../src/entity_pubsub"

describe "Entity management", ->
  em = new EntityManager

  beforeEach ->
    em = new EntityManager

  describe "#createEntity", ->
    it "should be truthy", ->
      entity1 = em.createEntity()
      entity1.should.not.be.null

    it "shouldn't be repeated", ->
      entity1 = em.createEntity()
      entity2 = em.createEntity()
      entity1.should.not.equal entity2

  describe "#removeEntity", ->
    it "should remove the entity", ->
      entity = em.createEntity()
      em.removeEntity entity
      em.entities.should.not.contain entity

  describe "#setComponent", ->
    it "should add a component to an entity", ->
      entity = em.createEntity()
      em.setComponent entity, "test",
        foo: "bar"
      components = em.getComponentsForEntity entity
      components.should.contain.key "test"

    it "should work for multiple entities", ->
      entity1 = em.createEntity()
      em.setComponent entity1, "test"
      entity2 = em.createEntity()
      em.setComponent entity2, "test"
      components1 = em.getComponentsForEntity entity1
      components2 = em.getComponentsForEntity entity2
      components1.should.contain.key "test"
      components2.should.contain.key "test"

  describe "#removeComponent", ->
    it "should remove component", ->
      entity = em.createEntity()
      em.setComponent entity, "test",
        foo: "bar"
      components = em.getComponentsForEntity entity
      components.should.contain.key "test"

      em.removeComponent entity, "test", true
      components = em.getComponentsForEntity entity
      components.should.not.contain.key "test"

  describe "#getComponentsForEntity", ->
    it "should add component to entity", ->
      entity = em.createEntity()
      components = em.getComponentsForEntity entity
      components.should.not.contain.key "test"
      em.setComponent entity, "test", 
        foo: "bar"
      components = em.getComponentsForEntity entity
      components.should.contain.key "test"

  describe "#getEntitiesWithComponents", ->
    it "should retrieve the correct entities", ->
      entityInclude1 = em.createEntity()
      em.setComponent entityInclude1, "include",
        foo: "bar"

      entityInclude2 = em.createEntity()
      em.setComponent entityInclude2, "include",
        foo: "bar"
      em.setComponent entityInclude2, "exclude",
        foo: "bar"

      entityExclude = em.createEntity()
      em.setComponent entityExclude, "exclude",
        foo: "bar"

      entities = em.getEntitiesWithComponents ["include"]
      entities.should.contain entityInclude1
      entities.should.contain entityInclude2
      entities.should.not.contain entityExclude

  describe "#subscribe", ->
    it "should create a component category", ->
      entity1 = em.createEntity()
      em.setComponent entity1, "test",
        foo: "bar"
      em.subscribe "testSubscriber", ["test"], (entities) ->
          entities.should.not.be.empty
        , (entities) ->
          entities.should.be.empty
      em.notify()

    it "should work for multiple entities", ->
      entity1 = em.createEntity()
      em.setComponent entity1, "test",
        foo: "bar"

      entity2 = em.createEntity()
      em.setComponent entity2, "test",
        foo: "bar"

      em.subscribe "testSubscriber", ["test"], (entities) ->
          entities.should.have.property entity1
          entities.should.have.property entity2
        , (entities) ->
          entities.should.be.empty
      em.notify()

  describe "#subscribe", ->
    it "should remove a component category", ->
      test = false
      entity1 = em.createEntity()
      em.setComponent entity1, "test",
        foo: "bar"
      em.subscribe "testSubscriber", ["test"], (entities) ->
          if test
            entities.should.be.empty
        , (entities) ->
          if test
            entities.should.not.be.empty
        , true
      em.removeComponent entity1, "test"
      test = true
      em.notify()
