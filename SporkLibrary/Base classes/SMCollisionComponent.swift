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
let SMCollisionComponentCanGoOffscreenKey               = "can go offscreen"            // Bool, determines if this can leave the screen (true by default)
let SMCollisionComponentBounceOffScreenEdges            = "bounce off screen edges"     // Bool, determines if object bounces when coming into contact with screen edges

// Collision detection types (as strings)
let SMCollisionComponentCollisionTypeCircleString       = "circle"
let SMCollisionComponnetCollisionTypeBoxString          = "box"

// Collision detection types (as numerical values)
enum SMCollisionComponentCollisionType : Int8 {
    case Circle = 0
    case Box    = 1
}


/*
 SMCollisionComponent
 
 A component that tracks collisions -- either with other similar components, or against the edges of the screen.
 */
class SMCollisionComponent : SMSpriteReferencingComponent {
    // MARK: - Instance variables
    
    // Collision type
    var collisionType = SMCollisionComponentCollisionType.Circle
    
    // Bounding box subtraction, basically the opposite of "padding." Used when the sprite's collision area is much smaller than the default frame of the SKSpriteNode
    var subtractedCollisionBoxWidth = CGFloat(0)
    var subtractedCollisionBoxHeight = CGFloat(0)
    //var collisionBox = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    // Collision circle data
    var boundingCircleRadius = CGFloat(0)
    
    // Determines whether or not to try to keep this entity on the screen (instead of flying away offscreen)
    var canGoOffscreen = true
    
    // Bounce off screen edges (instead of just stopping)
    var bounceOffScreenEdges = false
    
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
                //collisionType = SMCollisionComponentCollisionTypeCircle
                collisionType = .Circle
            } else if SMStringsAreSame(first: collisionTypeString, second: SMCollisionComponnetCollisionTypeBoxString) == true {
                //collisionType = SMCollisionComponentCollisionTypeBox;
                collisionType = .Box
            }
        }
        
        if let canGoOffscreenFlag = dictionary.object(forKey: SMCollisionComponentCanGoOffscreenKey) as? NSNumber {
            canGoOffscreen = canGoOffscreenFlag.boolValue
        }
        
        if let shouldBounceOffScreenEdges = dictionary.object(forKey: SMCollisionComponentBounceOffScreenEdges) as? NSNumber {
            bounceOffScreenEdges = shouldBounceOffScreenEdges.boolValue
        }
    }
    
    // MARK: - Bounding box
    
    // Returns an automatically-calculated radius for the sprite, minus any subtractions or adjustments
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
    
    // Returns an automatically-calculated CGRect frame, minus any subtractions or adjustments
    func adjustedCollisionBox() -> CGRect {
        if self.doesHaveSprite() == false {
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        // Get the default sprite hitbox
        var collisionBox = spriteNode!.frame
        
        // Adjust X and width
        collisionBox.origin.x       = collisionBox.origin.x     +   (subtractedCollisionBoxWidth * 0.5);
        collisionBox.size.width     = collisionBox.size.width   -   (subtractedCollisionBoxWidth * 0.5);
        
        // Adjust Y and height
        collisionBox.origin.y       = collisionBox.origin.y     +   (subtractedCollisionBoxHeight * 0.5);
        collisionBox.size.height    = collisionBox.size.height  -   (subtractedCollisionBoxHeight * 0.5);
        
        return collisionBox;
    }
    
    // MARK: - Distance checks
    
    // Distance to a sprite node
    func distanceFromSpriteNode(sprite:SKSpriteNode) -> CGFloat {
        if self.doesHaveSprite() == false {
            return SMCollisionComponentInvalidDistance
        }
        
        return SMMathDistanceBetweenPoints(first: sprite.position, second: spriteNode!.position)
    }
    
    // Distance from a sprite component
    func distanceFromSpriteComponent(component:SMSpriteComponent) -> CGFloat {
        if let theSprite = self.sprite() {
            if component.sprite != nil {
                return SMMathDistanceBetweenPoints(first: theSprite.position, second: component.sprite!.position)
            }
        }
        
        return SMCollisionComponentInvalidDistance
    }
    
    // Distance from another entity (which presumably has a working sprite component)
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
    
    // Check if a point is within the radius of the sprite
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
    
    // Checks if a point is within the sprite's CGRect frame
    func isPointCollidingWithCollisionBox(point:CGPoint) -> Bool {
        if self.doesHaveSprite() == false {
            return false
        }
        
        //return CGRectContainsPoint(self.adjustedCollisionBox(), point)
        return self.adjustedCollisionBox().contains(point)
    }
 
    // Checks if one collision component is within the radius of another collision component
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
    
    // Checks if this collision component is colliding with an entity (which presumably has its own collision component)
    func isCircleCollidingWithCircle(ofEntity:SMObject) -> Bool {
        // Check if the target entity has any collision components
        if let otherCollisionComponent = ofEntity.objectOfType(ofType: SMCollisionComponent.self) as? SMCollisionComponent {
            return self.isCircleCollidingWithCircle(circle: otherCollisionComponent)
        }
        
        return false
    }
    
    // MARK: - Offscreen handling
    
    // Function to determine if the entity is going offscreen and force it back 
    func forceToStayOnscreen() {
        if let theSprite = self.sprite() {
            var tooFarLeft = CGFloat(0)
            var tooFarRight = CGFloat(0)
            var tooFarUp = CGFloat(0)
            var tooFarDown = CGFloat(0)
            
            let screenLeft = CGFloat(0)
            let screenBottom = CGFloat(0)
            let screenRight = SMScreenWidthInPoints
            let screenTop = SMScreenHeightInPoints
            
            let distanceFromLeft = theSprite.position.x - screenLeft // left edge of screen
            let distanceFromRight = screenRight - theSprite.position.x
            let distanceFromBottom = theSprite.position.y - screenBottom
            let distanceFromTop = screenTop - theSprite.position.y
            
            switch(collisionType) {
            case .Circle:
                if boundingCircleRadius == 0 {
                    boundingCircleRadius = self.adjustedCollisionCircleRadius()
                }
                
                if distanceFromLeft < boundingCircleRadius {
                    tooFarLeft = boundingCircleRadius - distanceFromLeft
                    //print("Too far left = \(tooFarLeft) | Bounding circle radius: \(boundingCircleRadius)")
                }
                if distanceFromRight < boundingCircleRadius {
                    tooFarRight = boundingCircleRadius - distanceFromRight
                    //print("Too far right = \(tooFarRight) | Bounding circle radius: \(boundingCircleRadius)")
                }
                if distanceFromTop < boundingCircleRadius {
                    tooFarUp = boundingCircleRadius - distanceFromTop
                    //print("Distance from top = \(distanceFromTop) | Screen Top is \(screenTop)")
                    //print("Too far up = \(tooFarUp) | Bounding circle radius: \(boundingCircleRadius)")
                }
                if distanceFromBottom < boundingCircleRadius {
                    tooFarDown = boundingCircleRadius - distanceFromBottom
                    //print("Too far down = \(tooFarDown) | Bounding circle radius: \(boundingCircleRadius)")
                }
                
            case .Box:
                let box = self.adjustedCollisionBox()
                
                if distanceFromLeft < (box.width * 0.5) {
                    tooFarLeft = (box.width * 0.5) - distanceFromLeft
                }
                if distanceFromRight < (box.width * 0.5) {
                    tooFarRight = (box.width * 0.5) - distanceFromRight
                }
                if distanceFromTop < (box.height * 0.5) {
                    tooFarUp = (box.height * 0.5) - distanceFromTop
                }
                if distanceFromBottom < (box.height * 0.5) {
                    tooFarDown = (box.height * 0.5) - distanceFromBottom
                }
            } // end switch
            
            // apply any changes that have to be made (if the sprite is completely within screen bounds, this will all be zero)
            theSprite.position.x += tooFarLeft
            theSprite.position.x -= tooFarRight
            theSprite.position.y -= tooFarUp
            theSprite.position.y += tooFarDown
            
            // Determine if this should bounce
            if bounceOffScreenEdges == true && parent != nil {
                if let movementComponent = SMMovementComponentFromEntity(entity: parent!) {
                    if tooFarLeft != 0 || tooFarRight != 0 {
                        movementComponent.velocity.x *= -1.0
                    }
                    if tooFarUp != 0 || tooFarDown != 0 {
                        movementComponent.velocity.y *= -1.0
                    }
                }
            }
        } // end if let theSprite
    } // end function
    
    // MARK: - Update
    
    override func update(deltaTime: Double) {
        super.update(deltaTime: deltaTime)
        
        if canGoOffscreen == false {
            self.forceToStayOnscreen()
        }
    }
}
