Enity Pub/Sub
=============

Overview
--------
The purpose of this tool is to efficiently manage game state for use
in component systems.  It tracks runtime changes to entities and their
components, and passes this information to systems, which can deal with
it however they need.  The relationship between the entity manager and
component systems is managed through a pub/sub interface.  Systems
subscribe to a set of component classes, and register callbacks for three
events: Enter, Update and Exit.  Once this is done, the system will receive
events whenever entities with all of the specified components is added,
changed or removed.

Definitions
-----------
* *Entity* -- The basic unit of game state.  Entities don't hold any data
or logic themselves, the exist merely as handles used to attach these
elements.
* *Component* -- A component is a piece of data which can be attached to an
entity.
* *Component class* -- A component class describes a particular set of components
which can be added to entities.
* *System* -- A system is a piece of logic which runs on a set of entities.
Systems specify a set of components which an entity must have in order to
be processed.  An entity missing any of these components will be ignored
by the system.
