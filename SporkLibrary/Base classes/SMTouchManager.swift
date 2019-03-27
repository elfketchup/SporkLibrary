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
    
    // Touch Layers work like UI elements being on different windows in a desktop UI. An element on a foreground window would be
    // on a different "layer" than a UI element on the foreground window. Layers normally start at 1 (and move upwards), but
    // layers marked as zero (or negative) are considered to be "active" no matter what the current layer is. Additionally,
    // touch managers with a layer set to zero can interact with any touchable component that's been added to them regardless
    // of the component's actual layer value.
    var layer = Int(0) // default layer
    
    // MARK: - Layer functions
    
    func sameLayerAsComponent(component:SMTouchableComponent) -> Bool {
        if component.layer == self.layer {
            return true
        }
        
        return false
    }
    
    func canInteractWithComponent(component:SMTouchableComponent) -> Bool {
        if component.layer == self.layer || component.layer <= 0 || self.layer <= 0 {
            return true
        }
        
        return false
    }
    
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
                    if canInteractWithComponent(component: touchableComponent) {
                        touchableComponent.touchBeganAt(point: firstTouchPosition)
                    }
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
                    if canInteractWithComponent(component: touchableComponent) {
                        touchableComponent.touchMovedTo(point: firstTouchPosition, fromPreviousPoint: firstTouchPreviousPosition)
                    }
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
                    if canInteractWithComponent(component: touchableComponent) {
                        touchableComponent.touchEndedAt(point: firstTouchPosition)
                    }
                }
            }
        }
    }
    
    // MARK: - Update
    
    func removeUnusableTouchComponents() {
        if children == nil {
            return
        }
        if children!.count < 1 {
            return
        }
        
        for i in (0..<children!.count).reversed() {
            let currentEntity = children!.object(at: i) as! SMObject
            
            if let touchableComponent = SMTouchableComponentFromEntity(entity: currentEntity) {
                if touchableComponent.shouldBeRemovedFromTouchManager == true {
                    children!.removeObject(at: i)
                }
            }
        }
    }
    
    override func update(deltaTime: Double) {
        super.update(deltaTime: deltaTime)
        
        self.removeUnusableTouchComponents()
    }
}
