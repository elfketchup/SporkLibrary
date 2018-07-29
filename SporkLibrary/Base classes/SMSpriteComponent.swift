//
//  SMSpriteComponent.swift
//  SporkLibrary
//
//  Created by James on 6/20/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// MARK: - Dictionary keys
let SMSpriteComponentFilenameKey        = "filename"    // string, usually a PNG from the Assets.xcassets folder
let SMSpriteComponentXKey               = "x"           // CGFloat, x coordinate for sprite
let SMSpriteComponentYKey               = "y"           // CGFloat, y coordinate for sprite
let SMSpriteComponentZKey               = "z"           // CGFloat, z coordinate of sprite
let SMSpriteComponentSpriteNameKey      = "sprite name" // String, name used to find SKSpriteNode
let SMSpriteComponentSpriteNodeKey      = "sprite node" // SKSpriteNode, can be used to pass in an existing sprite node
let SMSpriteComponentColorKey           = "color"       // UIColor object

// Other constants
let SMSpriteComponentAnimationTag       = "animation tag" // used for finding animations actions started on SKSpriteNode by this class
let SMSpriteComponentInvalidDistance    = CGFloat(9001)

class SMSpriteComponent : SMObject {
    // MARK: - Class properties
    
    // The actual sprite node
    var sprite : SKSpriteNode? = nil
    
    // MARK: - Initializers
    
    init(withSpriteNode:SKSpriteNode) {
        super.init()
        sprite = withSpriteNode
    }
    
    override init(dictionary: NSDictionary) {
        super.init()
        self.loadFromDictionary(dictionary: dictionary)
    }
    
    // MARK: - Dictionary functions
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        var willUsePreviouslyExistingSprite = false
        var positionOfSprite                = CGPoint(x: 0, y: 0)
        var zPositionOfSprite               = CGFloat(0)
        
        if let existingSpriteNode = dictionary.object(forKey: SMSpriteComponentSpriteNodeKey) as? SKSpriteNode {
            sprite = existingSpriteNode
            willUsePreviouslyExistingSprite = true
            
            // Use the existing sprite's position as the "default" position for it to start in
            positionOfSprite = existingSpriteNode.position
        }
        
        if let filename = dictionary.object(forKey: SMSpriteComponentFilenameKey) as? String {
            if willUsePreviouslyExistingSprite == false {
                sprite = SKSpriteNode(imageNamed: filename)
            } else {
                print("[SKSpriteComponent] WARNING: Will override existing sprite with image loaded from: \(filename)")
                sprite = SKSpriteNode(imageNamed: filename)
            }
        }
        
        // Check if the sprite was still not loaded properly
        if sprite == nil {
            print("[SMSpriteComponent] ERROR: No sprite data could be loaded.")
            return;
        }
        
        // Try to load custom sprite positions from the dictionary
        if let xPosition = dictionary.object(forKey: SMSpriteComponentXKey) as? NSNumber {
            positionOfSprite.x = CGFloat(xPosition.doubleValue)
        }
        if let yPosition = dictionary.object(forKey: SMSpriteComponentYKey) as? NSNumber {
            positionOfSprite.y = CGFloat(yPosition.doubleValue)
        }
        if let zPosition = dictionary.object(forKey: SMSpriteComponentZKey) as? NSNumber {
            zPositionOfSprite = CGFloat(zPosition.doubleValue)
        }
        
        // Get the sprite name from the dictionary, if it exists
        if let spriteNameFromDictionary = dictionary.object(forKey: SMSpriteComponentSpriteNameKey) as? String {
            sprite!.name = spriteNameFromDictionary
        }
        
        // Set sprite position data
        sprite!.position = positionOfSprite
        sprite!.zPosition = zPositionOfSprite
        
        // Get color data
        if let spriteColor = dictionary.object(forKey: SMSpriteComponentColorKey) as? UIColor {
            self.setSpriteColor(color: spriteColor)
        }
    } // end function
    
    // MARK: - Adding or removing to parent entity
    
    
    override func willBeRemovedFromParent() {
        if sprite != nil {
            // remove the sprite from its parent node and stop all actions
            sprite!.removeAllActions()
            sprite!.removeFromParent()
            sprite = nil
        }
        
        super.willBeRemovedFromParent()
    }
    
    //override func willBeAddedToParent(object: SMObject) {
    //    parent = object;
    //}
    
    // MARK: - Color
    
    func setSpriteColor(color:UIColor) {
        if sprite == nil {
            return
        }
        
        sprite!.colorBlendFactor = 1.0
        sprite!.color = color
    }
    
    func spriteColor() -> UIColor? {
        if sprite != nil {
            return sprite!.color
        }
        
        return nil
    }
    
    func setAlpha(alpha:CGFloat) {
        if sprite != nil {
            sprite!.alpha = alpha
        }
    }
    
    func alpha() -> CGFloat {
        if sprite == nil {
            return CGFloat(0)
        }
        
        return sprite!.alpha
    }
    
    // MARK: - Rotation
    
    func rotationInRadians() -> CGFloat {
        if sprite == nil {
            return CGFloat(0)
        }
        
        return sprite!.zRotation
    }
    
    func rotationInDegrees() -> CGFloat {
        if sprite == nil {
            return CGFloat(0)
        }
        
        return SMRadiansToDegrees(radians: sprite!.zRotation)
    }
    
    func setRotation(degrees:CGFloat) {
        if sprite != nil {
            sprite!.zRotation = SMDegreesToRadians(degrees: degrees)
        }
    }
    
    func setRotation(radians:CGFloat) {
        if sprite != nil {
            sprite!.zRotation = radians
        }
    }
    
    // MARK: - Positioning
    
    // Set the sprite position as CGPoint
    func setPosition(point:CGPoint) {
        if sprite != nil {
            sprite!.position = point
        }
    }
    
    // Set the sprite position as CGFloats X and Y
    func setPositionAs(x:CGFloat, y:CGFloat) {
        if sprite != nil {
            sprite!.position = CGPoint(x: x, y: y)
        }
    }
    
    // Retrieve the sprite's position
    func position() -> CGPoint {
        if sprite == nil {
            return CGPoint(x: 0, y: 0)
        }
        
        return sprite!.position
    }
    
    // Set the sprite position as normalized coordinates (0,0 to 1,1)
    func setNormalizedPosition(point:CGPoint) {
        let normalizedX = point.x * SMScreenWidthInPoints
        let normalizedY = point.y * SMScreenHeightInPoints
        
        sprite!.position = CGPoint(x: normalizedX, y: normalizedY)
    }
    
    // Retrieve normalized position
    func normalizedPosition() -> CGPoint {
        if sprite == nil {
            return CGPoint(x: 0, y: 0)
        }
        
        let normalizedX = sprite!.position.x / SMScreenWidthInPoints
        let normalizedY = sprite!.position.y / SMScreenHeightInPoints
        
        return CGPoint(x: normalizedX, y: normalizedY)
    }
    
    func modifyPositionBy(x:CGFloat, y:CGFloat) {
        if sprite != nil {
            sprite!.position.x = sprite!.position.x + x
            sprite!.position.y = sprite!.position.y + y
        }
    }
    
    func modifyPositionBy(point:CGPoint) {
        if sprite != nil {
            sprite!.position.x = sprite!.position.x + point.x
            sprite!.position.y = sprite!.position.y + point.y
        }
    }
    
    func setZPosition(z:CGFloat) {
        if sprite != nil {
            sprite!.zPosition = z
        }
    }
    
    func zPosition() -> CGFloat {
        if sprite == nil {
            return CGFloat(0)
        }
        
        return sprite!.zPosition
    }
    
    func distanceFromSpriteComponent(component:SMSpriteComponent) -> CGFloat {
        if component.sprite == nil || sprite == nil {
            return SMSpriteComponentInvalidDistance
        }
        
        return SMMathDistanceBetweenPoints(first: component.sprite!.position, second: sprite!.position)
    }
    
    func distanceFromNode(node:SKNode) -> CGFloat {
        if sprite == nil {
            return SMSpriteComponentInvalidDistance
        }
        
        return SMMathDistanceBetweenPoints(first: sprite!.position, second: node.position)
    }
    
    // MARK: - Sprite parent relationship
    
    func spriteNodeHasParent() -> Bool {
        if sprite != nil {
            if sprite!.parent != nil {
                return true
            }
        }
        
        return false
    }
    
    func addToNode(node:SKNode) {
        if sprite != nil {
            node.addChild(sprite!)
        }
    }
    
    // MARK: - Animation
    
    // Animates the sprite, using an array of existing SKTexture objects.
    func applyAnimationWithTextures(arrayOfTextures:[SKTexture], animationDelay:Double, doesLoopRunForever:Bool) {
        if sprite == nil || arrayOfTextures.count < 1 {
            return;
        }
        
        var delay = animationDelay
        
        // Check for instantaneous animation delays, which would be invalid.
        if delay <= 0.0 {
            delay = 0.1; // 1/10th of a second animation delay; 10 animation frames per second
        }
        
        // Stop any existing animations
        if sprite!.action(forKey: SMSpriteComponentAnimationTag) != nil {
        //if let _ = sprite!.action(forKey: SMSpriteComponentAnimationTag) {
            sprite!.removeAction(forKey: SMSpriteComponentAnimationTag)
        }
        
        let animationAction = SKAction.animate(with: arrayOfTextures, timePerFrame: delay, resize: false, restore: true)
        
        if doesLoopRunForever == true {
            // Make this a repeatable action, and set it to use the SMSpriteComponentAnimationTag name so it can be found
            // (and stopped) later if necessary
            let runAnimationForeverAction = SKAction.repeatForever(animationAction)

            sprite!.run(runAnimationForeverAction, withKey: SMSpriteComponentAnimationTag)
        } else {
            sprite!.run(animationAction, withKey: SMSpriteComponentAnimationTag) // Otherwise, run just once
        }
    }
    
    /*
     This animates a sprite, using an array of filenames (which are then used to create SKTexture objects).
     After loading the SKTexture objects, this calls the 'applyAnimationWithTextures' to load the actual animation data.
    */
    func applyAnimationWithNamedFrames(arrayOfFrameNames:[String], animationDelay:Double, doesLoopForever:Bool) {
        if arrayOfFrameNames.count < 1 {
            return;
        }
        
        var arrayOfTextures = [SKTexture]()
        
        // Create the array of textures that will be used for animation
        for i in 0..<arrayOfFrameNames.count {
            // Create SKTexture object from the filenames passed in
            let currentName = arrayOfFrameNames[i]
            let tempTexture = SKTexture(imageNamed: currentName)
            // Add the newly created texture to the texture array
            arrayOfTextures.append(tempTexture)
        }
        
        //self.applyAnimationWithTextures(arrayOfTextures, animationDelay: animationDelay, doesLoopRunForever: doesLoopForever)
        self.applyAnimationWithTextures(arrayOfTextures: arrayOfTextures, animationDelay: animationDelay, doesLoopRunForever: doesLoopForever)
    }
}



// MARK: - Helper functions

func SMSpriteComponentFromEntity(entity:SMObject) -> SMSpriteComponent? {
    if let spriteComponent = entity.objectOfType(ofType: SMSpriteComponent.self) as? SMSpriteComponent {
        return spriteComponent
    }
    
    return nil
}

func SMSpriteNodeFromEntity(entity:SMObject) -> SKSpriteNode? {
    if let spriteComponent = entity.objectOfType(ofType: SMSpriteComponent.self) as? SMSpriteComponent {
        return spriteComponent.sprite
    }
    
    return nil
}
