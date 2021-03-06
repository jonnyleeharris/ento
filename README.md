# Ento

Ento is an entity component system framework built for Swift 2.0, inspired by [Ash](http://github.com/richardlord/Ash) and [Ashley](https://github.com/libgdx/ashley)

With thanks to artman's [Signals](https://github.com/artman/Signals) implementation.

#### Set- up

```swift
// Create engine
let engine:Engine = Engine();
		
// Add systems to engine
let system:TestSystem = TestSystem();
engine.addSystem(system, priority: 1);
		
// Create and add components to the entity.
let entity:Entity = Entity();
entity.add(TestComponentA());
entity.add(TestComponentB());
entity.add(TestComponentC());
		
// Add entity to engine
try! engine.addEntity(entity);
		
// Tick the engine.
// You should usually do this on a frame by frame basis, passing the delta time
// since the last tick.
let mockDeltaTime:Double = 1.0;
engine.update(mockDeltaTime);
```

##### Ticking the engine

You need to tick the engine manually by calling the update function of the engine, passing the delta time since the last update as a parameter.

In SpriteKit, it would be done as follows:

```swift
class GameScene: SKScene {

	private var prevUpdateTime:Double = 0;

	private let engine:Engine = Engine();
   
	 override func update(currentTime: CFTimeInterval) {		
		// Calculate delta time.
		if (self.prevUpdateTime <= 0) {
			self.prevUpdateTime = currentTime;
		}
		let deltaTime = currentTime - self.prevUpdateTime;
		self.prevUpdateTime = currentTime;

		engine.update(deltaTime);
	}
}
```

#### Example system

The following example shows how a system, interested in entities with both components TestComponentA and TestComponentB can access the components from matching entities and perform tick logic.

```swift
public class TestSystem : ListIteratingSystem {
	
	init() {
		// Here you pass a family to the super constructor. The family determines what components
		// an entity must have in order for this system to be interested in it.
		
		// Possible options:
		
		// All matches (i.e. AND)
		super.init(family: Family.all(TestComponentA.self, TestComponentB.self));
		
		// Any match (i.e. OR)
//		super.init(family: Family.any(TestComponentA.self, TestComponentB.self));
		
		// Exclude
//		super.init(family: Family.none(TestComponentD.self, TestComponentC.self));
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

}
```

#### License

Ento is released under an MIT license. See the LICENSE file for more information