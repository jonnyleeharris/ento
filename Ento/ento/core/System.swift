//
//  System.swift
//
//  Created by Jonathan Harris on 30/06/2015.
//  Copyright © 2015 Jonathan Harris. All rights reserved.
//

import Foundation

public class System : Hashable {
	
	private var hashNumber:Int;
	
	private static var hashCount:Int = 0;
	
	internal var engine:Engine?;	
	
	public var hashValue:Int {
		get {
			return hashNumber;
		}
	}		
	
	/**
	* Used internally to hold the priority of this system within the system list. This is
	* used to order the systems so they are updated in the correct order.
	*/
	internal var priority : Int = 0;
	
	/**
	* Called just after the system is added to the engine, before any calls to the update method.
	* Override this method to add your own functionality.
	*
	* @param engine The engine the system was added to.
	*/
	public func addToEngine( engine : Engine )
	{
		self.engine = engine;
	}
	
	/**
	* Called just after the system is removed from the engine, after all calls to the update method.
	* Override this method to add your own functionality.
	*
	* @param engine The engine the system was removed from.
	*/
	public func removeFromEngine( engine : Engine )
	{
	
	}
	
	/**
	* After the system is added to the engine, this method is called every frame until the system
	* is removed from the engine. Override this method to add your own functionality.
	*
	* <p>If you need to perform an action outside of the update loop (e.g. you need to change the
	* systems in the engine and you don't want to do it while they're updating) add a listener to
	* the engine's updateComplete signal to be notified when the update loop completes.</p>
	*
	* @param time The duration, in seconds, of the frame.
	*/
	public func update( time : Double )
	{
	
	}
	
	public init() {
		self.hashNumber = System.hashCount++;
	}
	
}

public func == (lhs:System, rhs:System) -> Bool {
	return lhs.hashValue == rhs.hashValue;
}