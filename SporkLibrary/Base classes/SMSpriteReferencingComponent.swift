//
//  SMSpriteReferencingComponent.swift
//  SporkLibrary
//
//  Created by James on 7/2/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// MARK: - Dictionary keys
let SMSpriteReferencingComponentSpriteComponentKey   = "sprite component"   // sprite component object
let SMSpriteReferencingComponentSpriteNodeKey        = "sprite node"        // SKSpriteNode object

/*
 SMSpriteReferencingComponent
 
 This class doesn't represent a "real" component, but is instead meant to be inherited from. Some other component types
 only work if the parent entity has a sprite component. This class was made so that it's not necessary to implement
 "search parent for sprite component" or "check if this component knows about a certain sprite" functionality in each of them.
 */

class SMSpriteReferencingComponent : SMObject {
    // Sprite node reference (presumably this sprite is from a sprite node held by a parent entity)
    var spriteNode : SKSpriteNode? = nil
    
    // Sprite component reference (presumably a sprite component held by the parent entity)
    var spriteComponent : SMSpriteComponent? = nil
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    init(withSpriteNode:SKSpriteNode) {
        super.init()
        spriteNode = withSpriteNode
    }
    
    init(withSpriteComponent:SMSpriteComponent) {
        super.init()
        spriteComponent = withSpriteComponent
    }
    
    override init(dictionary: NSDictionary) {
        super.init()
        self.loadFromDictionary(dictionary: dictionary)
    }
    
    // MARK: - Removal
    
    override func willBeRemovedFromParent() {
        spriteNode = nil
        spriteComponent = nil
        
        super.willBeRemovedFromParent()
    }
    
    // MARK: - Load data from dictionary
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        if let existingSprite = dictionary.object(forKey: SMSpriteReferencingComponentSpriteNodeKey) as? SKSpriteNode {
            spriteNode = existingSprite
        }
        
        if let existingSpriteComponent = dictionary.object(forKey: SMSpriteReferencingComponentSpriteComponentKey) as? SMSpriteComponent {
            spriteComponent = existingSpriteComponent
            
            if existingSpriteComponent.sprite != nil {
                spriteNode = existingSpriteComponent.sprite!
            } else {
                print("[SMSpriteReferencingComponent] WARNING: Was able to load sprite component from dictionary, but no associated sprite node could be found.")
            }
        }
    }
    
    // MARK: - Sprite retrieval
    
    func doesHaveSprite() -> Bool {
        if self.sprite() == nil {
            return false
        }
        
        return true
    }
    
    func sprite() -> SKSpriteNode? {
        // First, try to return the spriteNode stored by the instance of this class... if such a node exists
        if spriteNode != nil {
            return spriteNode
        }
        
        // Next, try to retrieve sprite node data from a linked sprite component, assuming it exists
        if spriteComponent != nil {
            if spriteComponent!.sprite != nil {
                spriteNode = spriteComponent!.sprite
                return spriteNode
            }
        }
        
        // Finally, try to get sprite component information from the parent entity
        if parent != nil {
            if let existingSpriteComponent = parent!.objectOfType(ofType: SMSpriteComponent.self) as? SMSpriteComponent {
                if existingSpriteComponent.sprite != nil {
                    spriteNode = existingSpriteComponent.sprite
                    return spriteNode
                }
            }
        }
        
        return nil // if nothing else works
    }
}
