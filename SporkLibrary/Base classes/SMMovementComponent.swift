//
//  SMMovementComponent.swift
//  SporkLibrary
//
//  Created by James on 6/24/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// MARK: - Dictionary keys
let SMMovementComponentVelocityXKey         = "velocity x" // CGFloat, determines horizontal velocity
let SMMovementComponentVelocityYKey         = "velocity y" // CGFloat, determines vertical velocity
let SMMovementComponentAccelerationXKey     = "acceleration x" // CGFloat, determines acceleration along x plane
let SMMovementComponentAccelerationYKey     = "acceleration y" // CGFloat, determines acceleration along y plane
let SMMovementComponentMotionTypeKey        = "motion type" // String, can be 'normal', 'stopped', or 'reversed'

// Movement types (as strings)
let SMMovementComponentMotionNormalString       = "normal" // normal way of moving, just adds things up normally
let SMMovementComponentMotionStoppedString      = "stopped" // no calculations performed, the object doesn't move
let SMMovementComponentMotionReversedString     = "reversed" // velocity calculations done so tha the object moves in reverse (to make things fly backwards?)
// Movement types (as 8-bit integers, to save memory)
let SMMovementComponentMotionNormal         = Int8(1)
let SMMovementComponentMotionStopped        = Int8(0)
let SMMovementComponentMotionReversed       = Int8(-1)

/*
 SMMovementComponent
 
 Used to move sprites (in sprite components) around.
 */
class SMMovementComponent : SMSpriteReferencingComponent {
    
    // The speed at which to move the sprite
    var velocity = CGPoint(x: 0, y: 0)
    
    // The rate at which to modify the velocity
    var acceleration = CGPoint(x: 0, y: 0)
    
    // Motion type
    var motionType = Int8(0) // set to "stopped" by default
    
    // MARK: - Initializer
    
    override init(withDictionary: NSDictionary) {
        super.init()
        self.loadFromDictionary(dictionary: withDictionary)
    }
    
    override init(withSpriteNode: SKSpriteNode) {
        super.init(withSpriteNode: withSpriteNode)
    }
    
    override init(withSpriteComponent: SMSpriteComponent) {
        super.init(withSpriteComponent: withSpriteComponent)
    }
    
    // MARK: - Loading from dictionary
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        // load velocity data
        if let velocityX = dictionary.object(forKey: SMMovementComponentVelocityXKey) as? NSNumber {
            velocity.x = CGFloat(velocityX.doubleValue)
        }
        if let velocityY = dictionary.object(forKey: SMMovementComponentVelocityYKey) as? NSNumber {
            velocity.y = CGFloat(velocityY.doubleValue)
        }
        
        // Load acceleration data
        if let accelX = dictionary.object(forKey: SMMovementComponentAccelerationXKey) as? NSNumber {
            acceleration.x = CGFloat(accelX.doubleValue)
        }
        if let accelY = dictionary.object(forKey: SMMovementComponentAccelerationYKey) as? NSNumber {
            acceleration.y = CGFloat(accelY.doubleValue)
        }
        
        // determine motion type
        if let motionTypeString = dictionary.object(forKey: SMMovementComponentMotionTypeKey) as? String {
            if SMStringsAreSame(first: motionTypeString, second: SMMovementComponentMotionNormalString) == true {
                motionType = SMMovementComponentMotionNormal
            } else if SMStringsAreSame(first: motionTypeString, second: SMMovementComponentMotionStoppedString) == true {
                motionType = SMMovementComponentMotionStopped
            } else if SMStringsAreSame(first: motionTypeString, second: SMMovementComponentMotionReversedString) == true {
                motionType = SMMovementComponentMotionReversed
            } else {
                print("[SMMovementComponent] Unknown movement type, will use 'normal' movement.")
                motionType = SMMovementComponentMotionNormal
            }
        }
    }
    
    // MARK: - Velocity and acceleration
    
    // Reset velocity to zero (no movement)
    func resetVelocity() {
        velocity = CGPoint(x: 0, y: 0)
    }
    
    // Reset acceleration to zero (no change in velocity)
    func resetAcceleration() {
        acceleration = CGPoint(x: 0, y: 0)
    }
    
    // Modify acceleration by CGPoint value
    func modifyAccelerationBy(point:CGPoint) {
        acceleration.x = acceleration.x + point.x
        acceleration.y = acceleration.y + point.y
    }
    
    // Modify velocity by CGPoint value
    func modifyVelocityBy(point:CGPoint) {
        velocity.x = velocity.x + point.x
        velocity.y = velocity.y + point.y
    }
    
    // MARK: - Updates
    
    /*
     Apply velocity changes to a particular sprite (presumably the sprite held by the parent entity's sprite component)
    */
    override func update(deltaTime: Double) {
        if let theSprite = self.sprite() {
            // Update velocity
            velocity.x = velocity.x + acceleration.x
            velocity.y = velocity.y + acceleration.y
            
            // Update sprite position
            switch( motionType ) {
            case SMMovementComponentMotionNormal: // normal motion
                theSprite.position.x = theSprite.position.x + velocity.x
                theSprite.position.y = theSprite.position.y + velocity.y;
                
            case SMMovementComponentMotionReversed: // reversed motion
                theSprite.position.x = theSprite.position.x - velocity.x
                theSprite.position.y = theSprite.position.y - velocity.y;
                
            default: // use normal motion by default
                theSprite.position.x = theSprite.position.x + velocity.x
                theSprite.position.y = theSprite.position.y + velocity.y;
            }
        }
    }
}
