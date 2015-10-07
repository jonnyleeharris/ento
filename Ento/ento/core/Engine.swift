//
//  Engine.swift
//
//  Created by Jonathan Harris on 30/06/2015.
//  Copyright © 2015 Jonathan Harris. All rights reserved.
//

import Foundation

public class Engine {
	
	private var entityNames:Dictionary<String, Entity>;
	
	private var entityList:Set<Entity>;
	
	private var systemList:Set<System>;
	
	private var families:Array<Family>;
	private var familyEntities:Dictionary<Family, EntitySet> = [:];
	
	/**
	* Indicates if the engine is currently in its update loop.
	*/
	public var updating:Bool = false;
	
	/**
	* Dispatched when the update loop ends. If you want to add and remove systems from the
	* engine it is usually best not to do so during the update loop. To avoid this you can
	* listen for this signal and make the change when the signal is dispatched.
	*/
	var updateComplete : Signal<Engine>;
	
	
	public init() {
		self.entityList = Set<Entity>();
		self.entityNames = [String: Entity]();
		self.systemList = Set<System>();
		self.families = [Family]();
		self.updateComplete = Signal<Engine>();
	}
	
	/**
	* Add an entity to the engine.
	*
	* @param entity The entity to add.
	*/
	public func addEntity( entity : Entity ) throws {
		
		if let _ = entityNames[entity.name] {
			throw EntoError.EntityAlreadyInUse
		} else {
			entityList.insert(entity);
			entityNames[ entity.name ] = entity;
			
			entity.componentAdded.listen(self, callback: componentAdded)
			entity.componentRemoved.listen(self, callback: componentRemoved)
			entity.nameChanged.listen(self, callback: entityNameChanged)
			
			// If the entity matches any of the existing families, insert it into
			// the family set for that family.
			for family in self.families {
				if(family.matches(entity)) {
					familyEntities[family]?.insert(entity);
				}
			}			
		}

	}
	
	/**
	* Remove an entity from the engine.
	*
	* @param entity The entity to remove.
	*/
	public func removeEntity( entity : Entity ) {
		
		entity.componentAdded.removeListener(self)
		entity.componentRemoved.removeListener(self)
		entity.nameChanged.removeListener(self)
		
		// Remove the entity from any of the entity sets.
		for entitySet:EntitySet in familyEntities.values {
			if(entitySet.contains(entity)) {
				entitySet.remove(entity);
			}
		}	
		
		self.entityNames.removeValueForKey(entity.name)
		self.entityList.remove(entity)

	}
	
	private func entityNameChanged(payload:EntityNameChanged) {
		if( entityNames[ payload.name ] == payload.entity )	{
			self.entityNames.removeValueForKey(payload.name)
			self.entityNames[payload.entity.name] = payload.entity;
		}
	}
	
	/**
	* Get an entity based n its name.
	*
	* @param name The name of the entity
	* @return The entity, or null if no entity with that name exists on the engine
	*/
	public func getEntityByName( name : String ) -> Entity? {
		return self.entityNames[ name ];
	}
	
	/**
	* Remove all entities from the engine.
	*/
	public func removeAllEntities() {
		while(entityList.count > 0) {
			removeEntity(entityList.removeFirst());
		}
	}
	
	/**
	* Returns a vector containing all the entities in the engine.
	*/
	public var entities:Array<Entity> {
		get {
			var result = [Entity]();
			for entity in self.entityList {
				result.append(entity);
			}
			return result;
		}
	}
	
	private func componentAdded(payload:EntityComponentAddedOrRemoved) {
		// If when a component is added, its entity matches any known families,
		// add that entity to the entity list for that family/
		for family in families {
			if(family.matches(payload.entity)) {
				familyEntities[family]?.insert(payload.entity);
			}
		}
	}
	
	private func componentRemoved(payload:EntityComponentAddedOrRemoved) {
		
		// When a component is removed from an entity, we check all known entity sets
		// for each family.
		// When we find a matching entity on a family, we determine if this entity should still belong
		// in the entity set for this family.
		// If it does not, we remove it.
		for family in families {
			if self.familyEntities[family]?.contains(payload.entity) != nil {
				if(!family.matches(payload.entity)) {
					familyEntities[family]?.remove(payload.entity);
				}
			}
		}
	}
	
	/**
	* Get a collection of nodes from the engine, based on the type of the node required.
	*
	* <p>The engine will create the appropriate NodeList if it doesn't already exist and
	* will keep its contents up to date as entities are added to and removed from the
	* engine.</p>
	*
	* <p>If a NodeList is no longer required, release it with the releaseNodeList method.</p>
	*
	* @param nodeClass The type of node required.
	* @return A linked list of all nodes of this type from all entities in the engine.
	*/
	public func getEntitySetForFamily( forFamily:Family ) -> EntitySet {
		
		if let result:EntitySet = self.familyEntities[forFamily] {
			return result;
		}

		self.families.append(forFamily);
		
		let newEntities:EntitySet = EntitySet();
		
		for entity in self.entities {
			if(forFamily.matches(entity) && !newEntities.contains(entity)) {
				newEntities.insert(entity);
			}
		}
		
		self.familyEntities[forFamily] = newEntities;
		
		
		// Recursive, but should work now due to the above lines setting the entity list
		// for this family.
		return getEntitySetForFamily(forFamily);


	}	
	
	/**
	* If a NodeList is no longer required, this method will stop the engine updating
	* the list and will release all references to the list within the framework
	* classes, enabling it to be garbage collected.
	*
	* <p>It is not essential to release a list, but releasing it will free
	* up memory and processor resources.</p>
	*
	* @param nodeClass The type of the node class if the list to be released.
	*/
	public func releaseNodeList( forFamily : Family ) {
		
		if let index = self.families.indexOf(forFamily) {
			self.families.removeAtIndex(index);
		}
		
		self.familyEntities.removeValueForKey(forFamily);

	}
	
	/**
	* Add a system to the engine, and set its priority for the order in which the
	* systems are updated by the engine update loop.
	*
	* <p>The priority dictates the order in which the systems are updated by the engine update
	* loop. Lower numbers for priority are updated first. i.e. a priority of 1 is
	* updated before a priority of 2.</p>
	*
	* @param system The system to add to the engine.
	* @param priority The priority for updating the systems during the engine loop. A
	* lower number means the system is updated sooner.
	*/
	public func addSystem( system : System, priority : Int ) {
		system.priority = priority;
		system.addToEngine( self );
		systemList.insert(system);
		sortSystems();
	}
	
	/**
	* Get the system instance of a particular type from within the engine.
	*
	* @param type The type of system
	* @return The instance of the system type that is in the engine, or
	* nil if no systems of this type are in the engine.
	*/
	public func getSystem<T:System>( systemType : T.Type ) -> T?	{
		let systemTypeName:String = String(systemType);
		for system in systemList {
			let systemClassName:String = String(system.dynamicType);
			if(systemClassName == systemTypeName) {
				return system as? T;
			}
		}
		return nil;
	}
	
	/**
	* Returns a vector containing all the systems in the engine.
	*/
	public var systems : Array<System> {
		get {
			var result = [System]();
			for system in systemList {
				result.append(system);
			}
			return result;
		}
	}
	
	/**
	* Remove a system from the engine.
	*
	* @param system The system to remove from the engine.
	*/
	public func removeSystem( system : System ) {
		if let system = systemList.remove( system ) {
			system.removeFromEngine( self );
			sortSystems();
		}
	}
	
	private var sortedSystems:Array<System>?
	
	private func sortSystems() {
		self.sortedSystems = self.systemList.sort({ (system1: System, system2: System) -> Bool in return system1.priority < system2.priority });
	}
	
	/**
	* Remove all systems from the engine.
	*/
	public func removeAllSystems() {
		while(systemList.count > 0) {
			let system:System = systemList.removeFirst();
			system.removeFromEngine(self);
		}
	}
	
	/**
	* Update the engine. This causes the engine update loop to run, calling update on all the
	* systems in the engine.
	*
	* <p>The package net.richardlord.ash.tick contains classes that can be used to provide
	* a steady or variable tick that calls this update method.</p>
	*
	* @time The duration, in seconds, of this update step.
	*/
	public func update( time : Double ) {
		updating = true;
		if let sortedSystems = self.sortedSystems {
			for system in sortedSystems {
				system.update(time);
			}
		}
		updating = false;
		updateComplete.fire(self);
	}
	
	
}
