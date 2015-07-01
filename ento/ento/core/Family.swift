//
//  Created by Jonathan Harris on 30/06/2015.
//  Copyright © 2015 Jonathan Harris. All rights reserved.
//

import Foundation

private enum MatchType : Int {
	case Any, All, None
}

public class FamilyBuilder {
	

	
}

public class Family : Hashable {
	
	private static var familyIndex:Int = 0;
	
	private var familyID:Int;
	
	private var matchType:MatchType;

	public var hashValue:Int {
		get {
			return self.familyID;
		}
	}
	
	private var components:Array<Any.Type>;
	
	private init(components : Array<Any.Type>, matchType:MatchType) {
		self.familyID = ++Family.familyIndex;
		self.components = [];
		for component in components {
			self.components.append(component);
		}		
		self.matchType = matchType;
	}
	
	public class func all(components: [Any.Type]) -> Family {
		return Family(components: components, matchType: MatchType.All);
	}
	
	public class func any(components: [Any.Type]) -> Family {
		return Family(components: components, matchType: MatchType.Any);
	}
	
	public class func none(components: [Any.Type]) -> Family {
		return Family(components: components, matchType: MatchType.None);
	}
	
	public func matches(entity:Entity) -> Bool {
		
		switch(self.matchType) {
			case .All: return matchAll(entity);
			case .Any: return matchAny(entity);
			case .None: return matchNone(entity);
		}
		
	}
	
	private func matchAll(entity:Entity) -> Bool {
		for match in self.components {
			if(!entity.has(match)) {
				return false;
			}
		}
		return true;
	}
	
	private func matchAny(entity:Entity) -> Bool {
		for match in self.components {
			if(entity.has(match)) {
				return true;
			}
		}
		return false;
	}
	
	private func matchNone(entity:Entity) -> Bool {
		for match in self.components {
			if(entity.has(match)) {
				return false;
			}
		}
		return true;
	}

}

public func == (lhs:Family, rhs:Family) -> Bool {
	return lhs.hashValue == rhs.hashValue;
}
