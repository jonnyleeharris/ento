import Foundation

public class TestSystem : ListIteratingSystem {
	
	init() {
		// Here you pass a family to the super constructor. The family determines what components
		// an entity must have in order for this system to be interested in it.
		
		// Possible options:
		
		// All matches (i.e. AND)
		super.init(family: Family.all([TestComponentA.self, TestComponentB.self]));
		
		// Any match (i.e. OR)
//		super.init(family: Family.any([TestComponentA.self, TestComponentB.self]));
		
		// Exclude
//		super.init(family: Family.none([TestComponentD.self, TestComponentC.self]));
	}
	
	// Override update entity to perform your ticking logic on the entity.
	override public func updateEntity(entity: Entity, deltaTime:Double) {
		super.updateEntity(entity, deltaTime: deltaTime);
		
		// This is how you get the components from the entity.
		// Note that you could probably safely unwrap the result.
		if let component:TestComponentA = entity.get(TestComponentA.self) {
			
			// Some component logic.
			component.value += deltaTime;
		}
	}
	
	override public func onEntityAddedToSystem(entity: Entity) {
		// Here you can perform one time only actions per entity when they are known to the system
		// This could be used in a RenderSystem, for instance - in which you might add a component's display node
		// to the scene.
	}
	
	override public func onEntityRemovedFromSystem(entity: Entity) {
		// Here you can perform one time only actions per entity when they are removed from the system
		// This could be used in a RenderSystem, for instance - in which you might remove a component's display node
		// from the scene.
	}
	
	var numEntities:Int {
		get {
			if let result = self.entitySet?.count {
				return result;
			} else {
				return 0;
			}
		}
	}
	
	
	

}
