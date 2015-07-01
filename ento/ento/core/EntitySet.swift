//
//  EntitySet.swift
//
//  Created by Jonathan Harris on 30/06/2015.
//  Copyright © 2015 Jonathan Harris. All rights reserved.
//

import Foundation

// TODO: Implement sequencable
public class EntitySet  {
	
	private (set) var entities:Set<Entity>;
	
	private (set) var onEntityAdded:Signal<Entity>;
	
	private (set) var onEntityRemoved:Signal<Entity>;
	
	init() {
		self.entities = Set<Entity>();
		self.onEntityAdded = Signal<Entity>();
		self.onEntityRemoved = Signal<Entity>();
	}
	
	public func insert(entity:Entity) {
		self.entities.insert(entity);
		onEntityAdded.fire(entity);
	}
	
	public func remove(entity:Entity) -> Entity? {
		if let result:Entity = self.entities.remove(entity) {
			onEntityRemoved.fire(result)
			return result;
		}
		return nil;
	}
	
	public var count:Int {
		get {
			return self.entities.count;	
		}
	}
	
	public func contains(entity:Entity) -> Bool {
		return self.entities.contains(entity);
	}

}
