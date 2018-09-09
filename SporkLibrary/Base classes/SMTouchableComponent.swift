//
//  SMTouchableComponent.swift
//  SporkLibrary
//
//  Created by James on 8/11/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

/*
 SMTouchableComponent
 
 A component that can respond to touch input
 */
class SMTouchableComponent : SMSpriteReferencingComponent {
    
    var respondsToTouch = true
    var isBeingTouched = false
    var startedTouchHere = false
    var endedTouchHere = false
    
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
    
    // MARK: - Input handling
    
    func didStartTouchAt(point:CGPoint) {
        // nothing
    }
    
    func didMoveTo(point:CGPoint) {
        // nothing done
    }
    
    func didMoveTo(point:CGPoint, previousPoint:CGPoint) {
        // nothing done
    }
    
    func didEndTouchAt(point:CGPoint) {
        // nothing done, handle "touch up" input here
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
