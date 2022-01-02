//
//  SMSideScrollComponent.swift
//  SporkLibrary
//
//  Created by James on 11/25/21.
//  Copyright © 2021 James Briones. All rights reserved.
//

import SpriteKit

// MARK: - Dictionary keys

let SMSideScrollComponentSpriteParallaxKey      = "parallax"   // parallax factor
let SMSideScrollComponentScrollSpeedXKey        = "scroll speed x"
let SMSideScrollComponentScrollSpeedYKey        = "scroll speed y"
//let SMSideScrollComponentSpriteNodeKey        = "sprite node"        // SKSpriteNode object

/*
 SMSideScrollComponent
 
 Works when moving sprites to the left or right, such as for parallax motion (in a side scroller or endless runner)
 
 */
class SMSideScrollComponent : SMSpriteReferencingComponent {
    
    // scrolling / motion information
    //var scrollSpeedX        = CGFloat( 0.0 ) // 1.0 is the normal scroll speed(?), 0 means at rest
    //var scrollSpeedY        = CGFloat( 0.0 ) // vertical scroll, probably unused in most side scrollers
    
    // 1.0 is the normal scroll speed, 0 means at rest
    var scrollSpeed         = CGPoint(x: 0, y: 0)
    
    // 1.0 is normal parallax, it moves at the same speed as the game's side scroll
    var parallaxFactor      = CGFloat( 1.0 )
    
    
    // MARK: - Initialization
    
    override init(dictionary: NSDictionary) {
        //super.init(dictionary: dictionary)
        super.init()
        self.loadFromDictionary(dictionary: dictionary)
    }
    
    init(withSprite:SKSpriteNode, parallax:CGFloat) {
        super.init()
        
        spriteNode = withSprite
        parallaxFactor = parallax
    }
    
    init(withSpriteComponent:SMSpriteComponent, parallax:CGFloat) {
        super.init()
        
        spriteComponent = withSpriteComponent
        parallaxFactor = parallax
        
        if spriteComponent!.sprite != nil {
            spriteNode = spriteComponent!.sprite!
        }
    }
    
    // MARK: - Modifying variables
    
    func setScrollSpeed(point:CGPoint) {
        scrollSpeed = point
    }
    
    func setScrollSpeed(x:CGFloat, y:CGFloat) {
        scrollSpeed = CGPoint(x: x, y: y)
    }
    
    // MARK: - Load from dictionary
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        var xSpeed = CGFloat(0)
        var ySpeed = CGFloat(0)
        
        if let parallaxValue = dictionary.object(forKey: SMSideScrollComponentSpriteParallaxKey) as? CGFloat {
            parallaxFactor = parallaxValue
        }
        if let scrollXValue = dictionary.object(forKey: SMSideScrollComponentScrollSpeedXKey) as? CGFloat {
            xSpeed = scrollXValue
        }
        if let scrollYValue = dictionary.object(forKey: SMSideScrollComponentScrollSpeedYKey) as? CGFloat {
            ySpeed = scrollYValue
        }
        
        setScrollSpeed(x: xSpeed, y: ySpeed)
    }
    
    // MARK: - Updates each frame
    
    override func update(deltaTime: Double) {
        // If there's no scrolling going on, then there's nothing to do
        if scrollSpeed.x == 0.0 && scrollSpeed.y == 0.0 {
            return
        }
        
        if let spriteObject = self.sprite() {
            let spriteX = spriteObject.position.x + (scrollSpeed.x * parallaxFactor)
            let spriteY = spriteObject.position.y + (scrollSpeed.y * parallaxFactor)
            
            spriteObject.position = CGPoint(x: spriteX, y: spriteY)
        }
    }
}
