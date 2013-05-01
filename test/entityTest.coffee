entitymanager = require '../src/entitymanager'
chai = require 'chai'
chai.should()


describe "Entity Creation", ->
    em = new entitymanager.EntityManager
    it "shouldn't be equal", ->
        entity1 = em.createEntity
        entity2 = em.createEntity
        entity1.should.equal entity2
