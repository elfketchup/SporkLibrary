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
    }
}

func SMDragSpriteComponentFromEntity(entity:SMObject) -> SMDragSpriteComponent? {
    if let component = entity.objectOfType(ofType: SMDragSpriteComponent.self) as? SMDragSpriteComponent {
        return component
    }
    
    return nil
}
