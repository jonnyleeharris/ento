//
//  ListIteratingEngine.swift
//  ash-swift
//
//  Created by Jonathan Harris on 30/06/2015.
//  Copyright © 2015 Jonathan Harris. All rights reserved.
//

import Foundation

public class ListIteratingSystem : FamilyMatchedSystem {
	
	override init(family: Family) {
		super.init(family: family);
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
	
	public func updateEntity(entity:Entity, deltaTime:Double) {
		
	}
	
	
}
