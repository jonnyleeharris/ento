//
//  ListIteratingEngine.swift
//  ash-swift
//
//  Created by Jonathan Harris on 30/06/2015.
//  Copyright © 2015 Jonathan Harris. All rights reserved.
//

import Foundation

public class ListIteratingSystem : System {
	
	private var family:Family;
	
	private (set) public var entitySet:EntitySet?
	
	public init(family:Family) {
		self.family = family;
		super.init();
	}
	
	override public func update(time: Double) {
		super.update(time);
		
		// Update all known entities in the entity set.
		if let entitySet = self.entitySet {
			for entity in entitySet.entities {
				updateEntity(entity, deltaTime: time);
			}
		}
	}
	
	override public func addToEngine(engine: Engine) {
		super.addToEngine(engine);
		
		// Store the entity set for the family.
		self.entitySet = engine.getEntitySetForFamily(self.family);
		
		if let entitySet = self.entitySet {
			// Set up listeners for when the entity set changes.
			entitySet.onEntityAdded.listen(self, callback: onEntityAddedToSystem);
			entitySet.onEntityRemoved.listen(self, callback: onEntityRemovedFromSystem);
			
			// Call on entity added for all entities in the set.
			for entity in entitySet.entities {
				onEntityAddedToSystem(entity);
			}
		}
		
	}
	
	override public func removeFromEngine( engine : Engine ) {
		super.removeFromEngine(engine);
		
		// Remove listeners on the entity set
		if let entitySet = self.entitySet {
			entitySet.onEntityAdded.removeListener(self);
			entitySet.onEntityRemoved.removeListener(self);
			
			// Call on entity removed for all entities in the set.
			for entity in entitySet.entities {
				onEntityRemovedFromSystem(entity);
			}
		}
		

	}
	
	public func onEntityAddedToSystem(entity:Entity) {
	}
	
	public func onEntityRemovedFromSystem(entity:Entity) {		
	}
	
	public func updateEntity(entity:Entity, deltaTime:Double) {
	}
	
	
	
}
