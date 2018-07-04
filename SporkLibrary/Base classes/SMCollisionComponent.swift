//
//  SMCollisionComponent.swift
//  SporkLibrary
//
//  Created by James on 7/1/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit
import CoreGraphics

let SMCollisionComponentInvalidDistance                 = CGFloat(9001)

// MARK: - Dictionary keys
let SMCollisionComponentSubtractCollisionBoxWidthKey    = "subtract collision width"    // CGFloat, sprite bounding box width - collision area width
let SMCollisionComponentSubtractCollisionBoxHeightKey   = "subtract collision height"   // CGFloat, sprite bounding box heigh - collision area height
let SMCollisionComponentBoundingCircleRangeKey          = "bounding circle radius"      // CGFloat, radius of collision detection circle
let SMCollisionComponentCollisionTypeKey                = "collision type"              // String, determines collision type

// Collision detection types (as strings)
let SMCollisionComponentCollisionTypeCircleString       = "circle"
let SMCollisionComponnetCollisionTypeBoxString          = "box"

// Collision detection types (as numbers
let SMCollisionComponentCollisionTypeCircle             = Int8(0)
let SMCollisionComponentCollisionTypeBox                = Int8(1)

class SMCollisionComponent : SMSpriteReferencingComponent {
    // MARK: - Instance variables
    
    // Collision type
    var collisionType = Int8(0)
    
    // Bounding box subtraction
    var subtractedCollisionBoxWidth = CGFloat(0)
    var subtractedCollisionBoxHeight = CGFloat(0)
    var collisionBox = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    // Collision circle data
    var boundingCircleRadius = CGFloat(0)
    
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
    
    // MARK: - Load from dictionary
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        if let subtractBoxWidth = dictionary.object(forKey: SMCollisionComponentSubtractCollisionBoxWidthKey) as? NSNumber {
            subtractedCollisionBoxWidth = CGFloat(subtractBoxWidth.doubleValue)
        }
        if let subtractBoxHeight = dictionary.object(forKey: SMCollisionComponentSubtractCollisionBoxHeightKey) as? NSNumber {
            subtractedCollisionBoxHeight = CGFloat(subtractBoxHeight.doubleValue)
        }
        if let circleRadius = dictionary.object(forKey: SMCollisionComponentBoundingCircleRangeKey) as? NSNumber {
            boundingCircleRadius = CGFloat(circleRadius.doubleValue)
        }
        
        if let collisionTypeString = dictionary.object(forKey: SMCollisionComponentCollisionTypeKey) as? String {
            if SMStringsAreSame(first: collisionTypeString, second: SMCollisionComponentCollisionTypeCircleString) == true {
                collisionType = SMCollisionComponentCollisionTypeCircle
            } else if SMStringsAreSame(first: collisionTypeString, second: SMCollisionComponnetCollisionTypeBoxString) == true {
                collisionType = SMCollisionComponentCollisionTypeBox;
            }
        }
    }
    
    // MARK: - Bounding box
    
    func adjustedCollisionCircleRadius() -> CGFloat {
        if self.doesHaveSprite() == false {
            return 0
        }
        
        let frame = spriteNode!.frame
        
        //print("Frame width: \(frame.width)\nFrame height: \(frame.height)")
        
        let estimatedSubtraction = (subtractedCollisionBoxHeight + subtractedCollisionBoxWidth) * 0.5
        let estimatedRadius = ((frame.width * 0.5) + (frame.height * 0.5)) * 0.5
        
        return (estimatedRadius - estimatedSubtraction)
    }
    
    func adjustedCollisionBox() -> CGRect {
        if self.doesHaveSprite() == false {
            //print("[SMCollisionComponent] WARNING: Trying to check for adjusted hit-box, but the sprite object doesn't exist!");
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        // Get the default sprite hitbox
        collisionBox = spriteNode!.frame
        
        // Adjust X and width
        collisionBox.origin.x       = collisionBox.origin.x     +   (subtractedCollisionBoxWidth * 0.5);
        collisionBox.size.width     = collisionBox.size.width   -   (subtractedCollisionBoxWidth * 0.5);
        
        // Adjust Y and height
        collisionBox.origin.y       = collisionBox.origin.y     +   (subtractedCollisionBoxHeight * 0.5);
        collisionBox.size.height    = collisionBox.size.height  -   (subtractedCollisionBoxHeight * 0.5);
        
        return collisionBox;
    }
    
    // MARK: - Distance checks
    
    func distanceFromSpriteNode(sprite:SKSpriteNode) -> CGFloat {
        if self.doesHaveSprite() == false {
            return SMCollisionComponentInvalidDistance
        }
        
        return SMMathDistanceBetweenPoints(first: sprite.position, second: spriteNode!.position)
    }
    
    func distanceFromSpriteComponent(component:SMSpriteComponent) -> CGFloat {
        if let theSprite = self.sprite() {
            if component.sprite != nil {
                return SMMathDistanceBetweenPoints(first: theSprite.position, second: component.sprite!.position)
            }
        }
        
        return SMCollisionComponentInvalidDistance
    }
    
    func distanceFromEntity(entity:SMObject) -> CGFloat {
        if let theSprite = self.sprite() {
            if let component = entity.objectOfType(ofType: SMSpriteComponent.self) as? SMSpriteComponent {
                if component.sprite != nil {
                    return SMMathDistanceBetweenPoints(first: component.sprite!.position, second: theSprite.position)
                }
            }
        }
        
        return SMCollisionComponentInvalidDistance
    }
    
    // MARK: - Collision checks
    
    // Check if a point is colliding with the "circle" (the
    func isPointCollidingWithCircle(point:CGPoint) -> Bool {
        if let theSprite = self.sprite() {
            if boundingCircleRadius == 0.0 {
                boundingCircleRadius = self.adjustedCollisionCircleRadius()
                print("Bounding circle radius set to: \(boundingCircleRadius)")
            }
            
            let distanceFromPoint = SMMathDistanceBetweenPoints(first: theSprite.position, second: point)
            if distanceFromPoint <= boundingCircleRadius {
                return true
            }
        }
        
        return false
    }
    
    func isPointCollidingWithCollisionBox(point:CGPoint) -> Bool {
        if self.doesHaveSprite() == false {
            return false
        }
        
        //return CGRectContainsPoint(self.adjustedCollisionBox(), point)
        return self.adjustedCollisionBox().contains(point)
    }
 
    func isCircleCollidingWithCircle(circle:SMCollisionComponent) -> Bool {
        if let ourSprite = self.sprite() {
            if let otherSprite = circle.sprite() {
                // If no circle data has been established, then try to create it
                if boundingCircleRadius == 0.0 {
                    boundingCircleRadius = self.adjustedCollisionCircleRadius()
                    //print("Bounding circle radius set to: \(boundingCircleRadius)")
                }
                
                let distanceBetweenCircles = SMMathDistanceBetweenPoints(first: ourSprite.position, second: otherSprite.position)
                if distanceBetweenCircles <= (boundingCircleRadius + circle.boundingCircleRadius) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func isCircleCollidingWithCircle(ofEntity:SMObject) -> Bool {
        // Check if the target entity has any collision components
        if let otherCollisionComponent = ofEntity.objectOfType(ofType: SMCollisionComponent.self) as? SMCollisionComponent {
            return self.isCircleCollidingWithCircle(circle: otherCollisionComponent)
        }
        
        return false
    }
}
