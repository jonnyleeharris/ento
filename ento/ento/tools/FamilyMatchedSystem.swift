//
//  FamilyMatchedSystem.swift
//  ento
//
//  Created by Jonathan Harris on 02/07/2015.
//
//

import Foundation

public class FamilyMatchedSystem : System {
	
	private var family:Family;
	
	private (set) public var entitySet:EntitySet?
	
	public init(family:Family) {
		self.family = family;
		super.init();
	}
	
	public override func update(time: Double) {
		super.update(time);
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

	
}
