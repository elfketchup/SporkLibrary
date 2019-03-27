//
//  SMTouchableComponent.swift
//  SporkLibrary
//
//  Created by James on 8/11/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// Dictionary keys
let SMTouchableComponentRespondsToTouchKey  = "responds to touch" // Bool, determines if it responds to touch right after being loaded

/*
 SMTouchableComponent
 
 A component that can respond to touch input
 */
class SMTouchableComponent : SMSpriteReferencingComponent {
    
    // The touch "layer" is similar to the concept of UI elements being on different windows in a desktop UI. A UI element on a window
    // in the background would be on a different layer than an element on the window that a user is working on. Layers start at 1,
    // and a touchable component with a layer marked as zero (or less) would be considered to be active no matter which actual layer
    // is currently in use.
    var layer = Int(0)
    
    var respondsToTouch     = true  // can be touched at all
    var isBeingTouched      = false // is currently being touched
    var startedTouchHere    = false // touch started on this component (and not on some other component or other area of screen)
    var endedTouchHere      = false // touch ended on this component (and not on another component or other area of the screen)
    
    // Track movement
    var touchBeganPoint = CGPoint(x: 0, y: 0)
    var touchMovedPoint = CGPoint(x: 0, y: 0)
    var touchEndedPoint = CGPoint(x: 0, y: 0)
    
    // Determines if this should be removed from SMTouchManager (or similar manager class) for some reason. Will usually be removed during update
    var shouldBeRemovedFromTouchManager = false
    
    // MARK: - Initializations
    
    /* these do nothing, but are included because Swift handles inheritance oddly */
    
    override init(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
    }
    
    override init(withSpriteNode: SKSpriteNode) {
        super.init(withSpriteNode: withSpriteNode)
    }
    
    override init(withSpriteComponent: SMSpriteComponent) {
        super.init(withSpriteComponent: withSpriteComponent)
    }
    
    // MARK: - Dictionary loading
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        if let respondToTouchValue = dictionary.object(forKey: SMTouchableComponentRespondsToTouchKey) as? NSNumber {
            respondsToTouch = respondToTouchValue.boolValue
        }
    }
    
    // MARK: - Distance handling
    
    func distanceFromTouchBeganToEnd() -> CGFloat {
        return SMMathDistanceBetweenPoints(first: touchBeganPoint, second: touchEndedPoint)
    }
    
    func horizontalDistanceFromTouchBeganToEnd() -> CGFloat {
        return touchEndedPoint.x - touchBeganPoint.x
    }
    
    func verticalDistanceFromTouchBeganToEnd() -> CGFloat {
        return touchEndedPoint.y - touchBeganPoint.y
    }
    
    func angleInDegreesFromTouchBeganToEnd() -> CGFloat {
        if touchBeganPoint.x == touchEndedPoint.x && touchBeganPoint.y == touchEndedPoint.y {
            return 0
        }
        
        return SMFindAngleBetweenPoints(original: touchBeganPoint, target: touchEndedPoint)
    }
    
    // MARK: - Input handling
    
    func didStartTouchAt(point:CGPoint) {
        // erase previous movement data
        touchMovedPoint = CGPoint(x: 0, y: 0)
        touchEndedPoint = CGPoint(x: 0, y: 0)
        
        touchBeganPoint = point
    }
    
    func didMoveTo(point:CGPoint) {
        touchMovedPoint = point
    }
    
    func didMoveTo(point:CGPoint, previousPoint:CGPoint) {
        touchMovedPoint = point
    }
    
    func didEndTouchAt(point:CGPoint) {
        touchEndedPoint = point
    }
    
    // MARK: - Touch input
    
    func touchBeganAt(point:CGPoint) {
        if respondsToTouch == false {
            return
        }
        
        if let spriteObject = self.sprite() {
            isBeingTouched = spriteObject.frame.contains(point)
            startedTouchHere = isBeingTouched
            
            if isBeingTouched == true {
                self.didStartTouchAt(point: point)
            }
        }
    }
    
    func touchMovedTo(point:CGPoint) {
        if respondsToTouch == false {
            return
        }
        
        if let spriteObject = self.sprite() {
            isBeingTouched = spriteObject.frame.contains(point)
            
            if isBeingTouched == true {
                self.didMoveTo(point: point)
            }
        }
    }
    
    func touchMovedTo(point:CGPoint, fromPreviousPoint:CGPoint) {
        if respondsToTouch == false {
            return
        }
        
        if let spriteObject = self.sprite() {
            isBeingTouched = spriteObject.frame.contains(point)
            
            if isBeingTouched == true {
                self.didMoveTo(point: point, previousPoint: fromPreviousPoint)
            }
        }
    }
    
    func touchEndedAt(point:CGPoint) {
        if respondsToTouch == false {
            return
        }
        
        if let spriteObject = self.sprite() {
            isBeingTouched = spriteObject.frame.contains(point)
            endedTouchHere = isBeingTouched
            
            if isBeingTouched == true {
                self.didEndTouchAt(point: point)
                isBeingTouched = false
            }
        }
    }
}

func SMTouchableComponentFromEntity(entity:SMObject) -> SMTouchableComponent? {
    if let component = entity.objectOfType(ofType: SMTouchableComponent.self) as? SMTouchableComponent {
        return component
    }
    
    return nil
}
