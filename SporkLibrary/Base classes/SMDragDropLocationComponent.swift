//
//  SMDragDropLocationComponent.swift
//  SporkLibrary
//
//  Created by James on 8/25/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

/*
 SMDragDropLocationComponent
 
 Used with SMDragSpriteComponent for dragging and dropping.
 */
class SMDragDropLocationComponent : SMSpriteReferencingComponent {
    
    // MARK: - Initialization
    
    override init(withSpriteNode: SKSpriteNode) {
        super.init(withSpriteNode: withSpriteNode)
    }
    
    override init(withSpriteComponent: SMSpriteComponent) {
        super.init(withSpriteComponent: withSpriteComponent)
    }
    
    // MARK: - Detection

    func dropzone() -> CGRect {
        if let spriteObject = self.sprite() {
            return spriteObject.frame
        }
        
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    // Determines if the middle of the sprite is inside this drag-and-drop sprite location
    func spriteIsInDropZone(spriteToCheck:SKSpriteNode) -> Bool {
        // is the center of the sprite in the drop zone?
        if self.dropzone().contains(spriteToCheck.position) == true {
            return true
        }
        
        return false
    }
    
    // MARK: - Moving sprite to drop zone
    
    func moveSpriteToDropzone(spriteToMove:SKSpriteNode, durationInSeconds:Double) {
        if let spriteObject = self.sprite() {
            // check if this should be instant
            if durationInSeconds <= 0.0 {
                spriteToMove.position = spriteObject.position
            } else {
                // create action for moving this sprite
                let moveAction = SKAction.move(to: spriteObject.position, duration: durationInSeconds)
                spriteToMove.run(moveAction, withKey: "SMDragDropLocationComponent")
            }
        }
    }
}
