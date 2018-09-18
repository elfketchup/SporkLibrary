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
    
    // Array of entities to check for sprite components; if sprites are within the boundaries of the drop zone,
    // then they'll be moved to the center of the drop zone
    var arrayOfEntitiesToCheck : NSArray? = nil
    
    // The duration (in seconds) that it takes for a sprite to be moved to the center of the drop zone
    var durationOfSpriteMovementInSeconds = Double(0.5)
    
    // Determines whether or not drag-and-drop functionality is active (false would make this inactive and not do anything)
    var dragDropIsActive = true
    
    // Determines if this component should wait until touch has ended on the SMDragSpriteComponent before doing any processing (true by default)
    var waitUntilTouchEnded = true
    
    // ID for drag-and-drop, drag components can be dragged here IF they have a value of zero (meaning "any") or if they have the
    // same ID number as this component.
    var dropID = 0
    
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
    
    // Determines if  the sprite should be moved to the center of the drop zone
    func spriteShouldMoveToDropZone(spriteToCheck:SKSpriteNode) -> Bool {
        // check if this should be inactive to begin with
        if dragDropIsActive == false {
            return false
        }
        
        guard let dropZoneSprite = self.sprite() else {
            return false
        }
        
        // check if both sprites are already in the exact same position
        if spriteToCheck.position.x == dropZoneSprite.position.x && spriteToCheck.position.y == dropZoneSprite.position.y {
            return false // no need to move since they're already in the same spot
        }
        
        return spriteIsInDropZone(spriteToCheck: spriteToCheck)
    }
    
    // MARK: - Moving sprite to drop zone
    
    func moveSpriteToDropzone(spriteToMove:SKSpriteNode, durationInSeconds:Double) {
        if let spriteObject = self.sprite() {
            // check if this should be instant
            if durationInSeconds <= 0.0 {
                spriteToMove.position = spriteObject.position
            } else {
                // only start the move action if there's no pre-existing "move to location" action being implemented on the sprite
                if spriteToMove.action(forKey: "SMDragDropLocationComponent") == nil {
                    // create action for moving this sprite
                    let moveAction = SKAction.move(to: spriteObject.position, duration: durationInSeconds)
                    spriteToMove.run(moveAction, withKey: "SMDragDropLocationComponent")
                }
            }
        }
    }
    
    // MARK: - Updates
    
    override func update(deltaTime: Double) {
        super.update(deltaTime: deltaTime)
        
        // check if this even should be doing anything
        if dragDropIsActive == false {
            return
        }
        
        if arrayOfEntitiesToCheck == nil {
            return
        }
        if arrayOfEntitiesToCheck!.count < 1 {
            return
        }
        
        // loop backwards through the array in case any objects get removed (unlikely to happen while this loop is running)
        for i in (0..<arrayOfEntitiesToCheck!.count).reversed() {
            let entity = arrayOfEntitiesToCheck!.object(at: i) as! SMObject
            
            if let dragSpriteComponent = SMDragSpriteComponentFromEntity(entity: entity) {
                
                var canInteractWithDragSpriteComponent = true
                
                // determine if the drag sprite component should NOT be interacted with
                if waitUntilTouchEnded == true && dragSpriteComponent.dragEnded == false {
                    canInteractWithDragSpriteComponent = false
                } else {
                    canInteractWithDragSpriteComponent = true
                }
                
                // Check if this drag sprite component has an invalid ID that doesn't match this (or it's non-zero, as zero means "any ID is fine")
                if dragSpriteComponent.dropID != 0 && dragSpriteComponent.dropID != self.dropID {
                    canInteractWithDragSpriteComponent = false // no interaction can be done
                }
                
                if canInteractWithDragSpriteComponent == true {
                    if let otherComponentSprite = dragSpriteComponent.sprite() {
                        // check if anything needs to be done with this sprite
                        if self.spriteShouldMoveToDropZone(spriteToCheck: otherComponentSprite) == true {
                            self.moveSpriteToDropzone(spriteToMove: otherComponentSprite, durationInSeconds: durationOfSpriteMovementInSeconds)
                        }
                    }
                }
            } // end if let dragspritecomponent
        } // end for loop
    } // end update
} // end class

func SMDragDropLocationComponentFromEntity(entity:SMObject) -> SMDragDropLocationComponent? {
    if let component = entity.objectOfType(ofType: SMDragDropLocationComponent.self) as? SMDragDropLocationComponent {
        return component
    }
    
    return nil
}
