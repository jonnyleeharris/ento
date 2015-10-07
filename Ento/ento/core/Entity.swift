//
//  Created by Jonathan Harris on 29/06/2015.
//  Copyright © 2015 Jonathan Harris. All rights reserved.
//

import Foundation

struct EntityComponentAddedOrRemoved {
	var componentClass:Any.Type;
	var entity:Entity;
}

struct EntityNameChanged {
	var name:String;
	var entity:Entity;
}

public class Entity : Hashable {
	
	private static var nameCount:Int = 0;
	
	private static var hashCount:Int = 0;
	
	private var hashNumber:Int;
	
	public var numComponents:Int {
		get {
			return components.count;
		}
	}
	
	/**
	* All entities have a name. If no name is set, a default name is used. Names are used to
	* fetch specific entities from the engine, and can also help to identify an entity when debugging.
	*/
	var name : String {
		didSet {
			self.nameChanged.fire( EntityNameChanged(name: oldValue, entity: self) );
		}
	}
	
	public var hashValue:Int {
		get {
			return self.hashNumber;
		}
	}
	
	/**
	* This signal is dispatched when a component is added to the entity.
	*/
	private (set) var componentAdded:Signal<EntityComponentAddedOrRemoved>;
	
	/**
	* This signal is dispatched when a component is removed from the entity.
	*/
	private (set) var componentRemoved:Signal<EntityComponentAddedOrRemoved>;
	
	/**
	* Dispatched when the name of the entity changes. Used internally by the engine to track entities based on their names.
	*/
	internal var nameChanged:Signal<EntityNameChanged>;
	
	internal var previous:Entity?;
	
	internal var next:Entity?;
	
	internal var components:Dictionary<String, Any>;
	
	public init(name:String) {
		self.componentAdded = Signal<EntityComponentAddedOrRemoved>()
		self.componentRemoved = Signal<EntityComponentAddedOrRemoved>()
		self.nameChanged = Signal<EntityNameChanged>();
		self.name = name;
		self.hashNumber = Entity.hashCount++
		self.components = [String: Any]();
	}
	
	public convenience init() {
		let name:String = "entity\(++Entity.nameCount)";
		self.init(name: name);
	}
	
	public func add(component:Any) {
		let key:String = String(component.dynamicType);

		if let existing = self.components[key] {
			remove(existing.dynamicType);
		}
		
		self.components[key] = component;
		
		self.componentAdded.fire( EntityComponentAddedOrRemoved(componentClass: component.dynamicType, entity: self) );
	}
	
	public func remove(componentClass:Any.Type) -> Any? {
		let key:String = String(componentClass);
		
		if let existing:Any = self.components.removeValueForKey(key) {
			
			self.componentRemoved.fire( EntityComponentAddedOrRemoved(componentClass: existing.dynamicType, entity: self) );
			return existing;
		} else {
			return nil;
			
		}
	}
	
	public func get<T>(componentType:T.Type) -> T? {
		let key:String = String(componentType);
		return self.components[key] as? T;
	}
	
//	public func getAll() -> Array<Any> {
//		return [Any](self.components.values)
//	}
	
	public func has(componentType:AnyClass) -> Bool {
		let key:String = String(componentType);
		return self.components.keys.contains(key)
//		if let _ = self.components[key] {
//			return true;
//		} else {
//			return false;
//		}
	}
	
}

public func == (lhs:Entity, rhs:Entity) -> Bool {
	return lhs.hashValue == rhs.hashValue;
}
