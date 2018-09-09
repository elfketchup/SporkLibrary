//
//  SMDragSpriteComponent.swift
//  SporkLibrary
//
//  Created by James on 8/9/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// add to entity to allow the sprite to be dragged around (and dropped into certain areas)
class SMDragSpriteComponent : SMTouchableComponent {
    
    var canBeDragged = true
    
    var dropID = 0 // Used for identifying a valid place to drag-and-drop
    
    var dropSpots : NSArray? = nil // array of "drag and drop" locations
    
    var dragEnded = false
    
    // MARK: - Input handling
    
    override func didMoveTo(point: CGPoint) {
        if canBeDragged == false {
            return
        }
        
        if let spriteObject = self.sprite() {
            
            if startedTouchHere == true {
                spriteObject.position = point
            }
        }
        
        dragEnded = false
    }
    
    override func touchBeganAt(point: CGPoint) {
        super.touchBeganAt(point: point)
        dragEnded = false
    }
    
    override func touchEndedAt(point: CGPoint) {
        super.touchBeganAt(point: point)
        dragEnded = true
        print("Drag ended = \(dragEnded)")
    }
}

func SMDragSpriteComponentFromEntity(entity:SMObject) -> SMDragSpriteComponent? {
    if let component = entity.objectOfType(ofType: SMDragSpriteComponent.self) as? SMDragSpriteComponent {
        return component
    }
    
    return nil
}
