//
//  Created by Jonathan Harris on 29/06/2015.
//  Copyright © 2015 Jonathan Harris. All rights reserved.
//

import XCTest

class Tests: XCTestCase {
	
	// Tests need work.
	
	// Need separating into separate tests etc.
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testFamilyMatching() {
		let entity:Entity = Entity();

		assert(!Family.all(TestComponentA.self).matches(entity));
		
		assert(!Family.all(TestComponentB.self).matches(entity));
		
		assert(Family.none(TestComponentB.self).matches(entity));
		
		entity.add(TestComponentA());
		entity.add(TestComponentB());
		
		assert(Family.all(TestComponentA.self, TestComponentB.self).matches(entity));
		
		assert(!Family.any(TestComponentC.self).matches(entity));
		assert(Family.any(TestComponentA.self).matches(entity));
	}
	
	func testEntityComponents() {
		let entity:Entity = Entity();
		
		assert(entity.numComponents == 0);
		
		entity.add(TestComponentB());
		assert(entity.numComponents == 1);
		assert(entity.has(TestComponentB));
		assert(!entity.has(TestComponentA));
		
		entity.add(TestComponentA());
		assert(entity.has(TestComponentA));
		assert(entity.numComponents == 2);
		
		entity.add(TestComponentA());
		assert(entity.has(TestComponentA));
		assert(entity.numComponents == 2);
		
	}
	
	func testLotsOfEntities() {
		// Create engine
		let engine:Engine = Engine();
		
		// Add systems to engine
		let system:TestSystem = TestSystem();
		engine.addSystem(system, priority: 1);
		
		// Create entity with inspectable component
		let component:TestComponentA = TestComponentA();
		assert(component.value == 0);
		
		var entity:Entity;
		let numEntities:Int = 1000;
		for _ in 1...numEntities {
			entity = Entity();
			entity.add(component);
			
			// Add entity to engine
			try! engine.addEntity(entity);
		}
		
		assert(engine.entities.count == numEntities);

	}
	
	func testDocumentation() {
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
	}
	
	func testSystemTick() {
		// Create engine
		let engine:Engine = Engine();
		
		// Add systems to engine
		let system:TestSystem = TestSystem();
		engine.addSystem(system, priority: 1);
		
		// Create entity with inspectable component
		let component:TestComponentA = TestComponentA();
		assert(component.value == 0);
		
		let entity:Entity = Entity();
		entity.add(component);
		
		// Add entity to engine
		try! engine.addEntity(entity);
		
		// Do some ticking.
		
		let deltaTime:Double = 1.0;
		for index in 1...100 {
			engine.update(deltaTime);
			
			// Expect each delta to increase components value by the delta (thats what the system does).
			assert(component.value == (deltaTime  * Double(index)))
		}
		

	}
    
    func testSystemEntitiesCount() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		
		// Create engine
		let engine:Engine = Engine();
		
		// Add systems to engine
		let system:TestSystem = TestSystem();
		engine.addSystem(system, priority: 1);
		
		// Add entities to engine
		
		do {
			
			// System entities should be 0
			assert(system.numEntities == 0);

			// Create an entity that conforms to system family
			var ent:Entity = Entity();
			ent.add(TestComponentA());
			try engine.addEntity(ent);
			
			// Should now have 1 entity in system
			assert(system.numEntities == 1);
			
			// Remove entity from system
			engine.removeEntity(ent);
			
			// Should now have 0 entities in system
			assert(system.numEntities == 0);

			// Add a non-family-confirming entity to system
			ent = Entity();
			try engine.addEntity(ent);
			ent.add(TestComponentB());
			
			// Num entities should still be 0
			assert(system.numEntities == 0);
			
			// Add component to entity to make the entity
			// conform to the family.
			ent.add(TestComponentA());
			
			// Num entities in system should now be 1
			assert(system.numEntities == 1);
			
			// Remove component from entity so it is no longer conforming
			ent.remove(TestComponentA.self);
			
			// We should no longer have entities in the system.
			assert(system.numEntities == 0);
			
		} catch {
			
		}
		
		engine.update(1);
		
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
