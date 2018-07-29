//
//  SMBarDisplayComponent.swift
//  SporkLibrary
//
//  Created by James on 7/25/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// MARK: - Dictionary keys
let SMBarDisplayComponentStartingLengthKey      = "length"  // CGFloat, length that it starts with (1.0 is default)
let SMBarDisplayComponentBaseZKey               = "z"       // CGFloat, base Z for all sprites
let SMBarDisplayComponentPositionXKey           = "x"       // CGFloat, x coordinate where sprites are centered around
let SMBarDisplayComponentPositionYKey           = "y"       // CGFloat, y coordinate where sprites are centered around



enum SMBarDisplayComponentAlignment : Int8 {
    case Left       = 0 // Left aligned, starts from left and goes right when 100%
    case Right      = 1 // Right-aligned, starts from right and goes left when 100%
    case Center     = 2 // Center-aligned, starts in center and grows both left and right when 100%
}

/*
 SMBarDisplayComponent
 
 Can be used to display UI components like loading bars and health bars.
 */
class SMBarDisplayComponent : SMObject {
    
    private var _length = CGFloat(1.0)
    var length : CGFloat {
        get {
            return _length
        }
        set(value) {
            _length = value
            updateBarDisplay()
        }
    }
    
    private var _baseZ = CGFloat(1.0)
    var z : CGFloat {
        get{
            return _baseZ
        }
        set(value) {
            _baseZ = value
            updateZPositions()
        }
    }
    
    private var _position = CGPoint(x: 0, y: 0)
    var position : CGPoint {
        get {
            return _position
        }
        set(value) {
            _position = value
            updatePositions()
        }
    }
    
    var barSprite : SKSpriteNode? = nil
    
    var backgroundBar : SKSpriteNode? = nil
    
    var labelNode : SMTextNode? = nil
    
    // MARK: - Initializers
    
    init(sprite:SKSpriteNode) {
        super.init()
        barSprite = sprite
        
        _baseZ = sprite.zPosition
        _position = sprite.position
        updateZPositions()
        updateBarDisplay()
    }
    
    init(sprite:SKSpriteNode, backgroundSprite:SKSpriteNode) {
        super.init()
        barSprite = sprite
        backgroundBar = backgroundSprite
        
        _position = sprite.position
        _baseZ = backgroundSprite.zPosition
        updateZPositions()
        updateBarDisplay()
    }
    
    init(labelText:String, sprite:SKSpriteNode, backgroundSprite:SKSpriteNode) {
        super.init()
        barSprite = sprite
        backgroundBar = backgroundSprite
        setLabelText(string: labelText)
        
        _position = sprite.position
        _baseZ = backgroundSprite.zPosition
        updateZPositions()
        updateBarDisplay()
    }
    
    init(barSpriteName:String) {
        super.init()
        barSprite = SKSpriteNode(imageNamed: barSpriteName)
        
        updateZPositions()
        updateBarDisplay()
    }
    
    init(barSpriteName:String, backgroundBarName:String) {
        super.init()
        barSprite = SKSpriteNode(imageNamed: barSpriteName)
        backgroundBar = SKSpriteNode(imageNamed: backgroundBarName)
        
        updateZPositions()
        updateBarDisplay()
    }
    
    init(labelText:String, barSpriteName:String, backgroundBarName:String) {
        super.init()
        barSprite = SKSpriteNode(imageNamed: barSpriteName)
        backgroundBar = SKSpriteNode(imageNamed: backgroundBarName)
        setLabelText(string: labelText)
        
        updateZPositions()
        updateBarDisplay()
    }
    
    override init(dictionary: NSDictionary) {
        super.init()
        self.loadFromDictionary(dictionary: dictionary)
    }
    
    // MARK: - Dictionary loading
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
    }
 
    // MARK: - Label functions
    
    func setLabelText(string:String) {
        
    }
    
    // MARK: - Sprite positions
    
    func parentNode() -> SKNode? {
        return nil
    }
    
    func updateZPositions() {
        
    }
    
    func updatePositions() {
        
    }
    
    func updateBarDisplay() {
        self.updatePositions()
    }
    
}
