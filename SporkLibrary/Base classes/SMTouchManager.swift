//
//  SMTouchManager.swift
//  SporkLibrary
//
//  Created by James on 8/12/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

/*
 SMTouchManager
 
 A simple manager meant to handle touches, mainly by passing along touch input messages to any entity
 that contains an SMTouchableComponent (or one of its subclasses).
 */
class SMTouchManager : SMObject {
    
    // MARK: - Input handling
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent?, node:SKNode) {
        if children == nil || children!.count < 1 {
            return
        }
        
        if let firstTouch = touches.first {
            let firstTouchPosition = firstTouch.location(in: node)
            
            for i in 0..<children!.count {
                let entity = children!.object(at: i) as! SMObject
                if let touchableComponent = SMTouchableComponentFromEntity(entity: entity) {
                    touchableComponent.touchBeganAt(point: firstTouchPosition)
                }
            }
        }
    }
    
    func touchesMoved(touches: Set<UITouch>, event: UIEvent?, node:SKNode) {
        if children == nil  || children!.count < 1 {
            return
        }
        
        if let firstTouch = touches.first {
            let firstTouchPosition = firstTouch.location(in: node)
            let firstTouchPreviousPosition = firstTouch.previousLocation(in: node)
            
            for i in 0..<children!.count {
                let entity = children!.object(at: i) as! SMObject
                if let touchableComponent = SMTouchableComponentFromEntity(entity: entity) {
                    touchableComponent.touchMovedTo(point: firstTouchPosition, fromPreviousPoint: firstTouchPreviousPosition)
                }
            }
        }
    }
    
    func touchesEnded(touches: Set<UITouch>, event: UIEvent?, node:SKNode) {
        if children == nil || children!.count < 1 {
            return
        }
        
        if let firstTouch = touches.first {
            let firstTouchPosition = firstTouch.location(in: node)
            
            for i in 0..<children!.count {
                let entity = children!.object(at: i) as! SMObject
                if let touchableComponent = SMTouchableComponentFromEntity(entity: entity) {
                    touchableComponent.touchEndedAt(point: firstTouchPosition)
                }
            }
        }
    }
}
