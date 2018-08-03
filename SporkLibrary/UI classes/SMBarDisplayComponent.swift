//
//  SMBarDisplayComponent.swift
//  SporkLibrary
//
//  Created by James on 7/25/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// MARK: - Dictionary keys
let SMBarDisplayComponentStartingLengthKey      = "length"          // CGFloat, length that it starts with (1.0 is default)
let SMBarDisplayComponentBaseZKey               = "z"               // CGFloat, base Z for all sprites
let SMBarDisplayComponentPositionXKey           = "x"               // CGFloat, x coordinate where sprites are centered around
let SMBarDisplayComponentPositionYKey           = "y"               // CGFloat, y coordinate where sprites are centered around
let SMBarDisplayComponentBarAlignmentKey        = "alignment"       // String, determines whether the bar grows from the left, center, or right
let SMBarDisplayComponentTextAlignmentKey       = "text position"   // String, determines whether the text is positioned relative to display bar
let SMBarDisplayComponentBarSpriteNameKey       = "bar sprite name" // String, filename used to load bar sprite node
let SMBarDisplayComponentBackgroundBarNameKey   = "background name" // String, filename used to load background sprite node
let SMBarDispalyComponentLabelTextKey           = "label text"      // String, text for label node displayed over bar

// String values for bar alignment
let SMBarDisplayComponentAlignmentStringLeft    = "left"
let SMBarDisplayComponentAlignmentStringRight   = "right"
let SMBarDisplayComponentAlignmentStringCenter  = "center"

// String values for text alignment
//let SMBar

enum SMBarDisplayComponentAlignment : Int8 {
    case Left       = 0 // Left aligned, starts from left and goes right when 100%
    case Right      = 1 // Right-aligned, starts from right and goes left when 100%
    case Center     = 2 // Center-aligned, starts in center and grows both left and right when 100%
}

enum SMBarDisplayComponentTextPosition : Int8 {
    case Center     = 1 // Text appears in exact middle of display bar
    case Above      = 2 // text appears above the bar
    case Below      = 3 // Text appears below the bar
    case Left       = 4 // Text appears left-justified in left edge of the bar
    case Right      = 5 // Text appears right-justified
}

/*
 SMBarDisplayComponent
 
 Can be used to display UI components like loading bars and health bars.
 */
class SMBarDisplayComponent : SMObject {
    
    private var _length         = CGFloat(1.0)
    private var _baseZ          = CGFloat(1.0)
    private var _position       = CGPoint(x: 0, y: 0)
    private var _barAlignment   = SMBarDisplayComponentAlignment.Center
    private var _textAlignment  = SMBarDisplayComponentTextPosition.Center
    
    var barSprite : SKSpriteNode?       = nil
    var backgroundBar : SKSpriteNode?   = nil
    var labelNode : SMTextNode?         = nil
    
    // MARK: - Getter and setters for variables
    
    var barAlignment : SMBarDisplayComponentAlignment {
        get {
            return _barAlignment
        }
        set(value) {
            _barAlignment = value
            updateBarAlignment()
        }
    }
    
    var textAlignment : SMBarDisplayComponentTextPosition {
        get {
            return _textAlignment
        }
        set(value) {
            _textAlignment = value
            updateTextPosition()
        }
    }
    
    var length : CGFloat {
        get {
            return _length
        }
        set(value) {
            _length = value
            updateBarDisplay()
        }
    }
    
    var z : CGFloat {
        get{
            return _baseZ
        }
        set(value) {
            _baseZ = value
            updateZPositions()
        }
    }
    
    var position : CGPoint {
        get {
            return _position
        }
        set(value) {
            _position = value
            updatePositions()
        }
    }
    
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
        
        updateZPositions()
        updateBarDisplay()
    }
    
    // MARK: - Dictionary loading
    
    /*
     // MARK: - Dictionary keys
     let SMBarDisplayComponentBaseZKey               = "z"               // CGFloat, base Z for all sprites
     let SMBarDisplayComponentPositionXKey           = "x"               // CGFloat, x coordinate where sprites are centered around
     let SMBarDisplayComponentPositionYKey           = "y"               // CGFloat, y coordinate where sprites are centered around
     let SMBarDisplayComponentBarAlignmentKey        = "alignment"       // String, determines whether the bar grows from the left, center, or right
     let SMBarDisplayComponentTextAlignmentKey       = "text position"   // String, determines whether the text is positioned relative to display bar
     let SMBarDisplayComponentBarSpriteNameKey       = "bar sprite name" // String, filename used to load bar sprite node
     let SMBarDisplayComponentBackgroundBarNameKey   = "background name" // String, filename used to load background sprite node
     let SMBarDispalyComponentLabelTextKey           = "label text"      // String, text for label node displayed over bar
     
     // String values for bar alignment
     let SMBarDisplayComponentAlignmentStringLeft    = "left"
     let SMBarDisplayComponentAlignmentStringRight   = "right"
     let SMBarDisplayComponentAlignmentStringCenter  = "center"
 */
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        if let startingLengthValue = dictionary.object(forKey: SMBarDisplayComponentStartingLengthKey) as? NSNumber {
            let lengthCastToFloat = CGFloat(startingLengthValue.doubleValue)
            _length = SMClampFloat(input: lengthCastToFloat, min: 0.0, max: 1.0)
        }
        
        // get coordinates
        if let xValue = dictionary.object(forKey: SMBarDisplayComponentPositionXKey) as? NSNumber {
            position.x = CGFloat(xValue.doubleValue)
        }
        if let yValue = dictionary.object(forKey: SMBarDisplayComponentPositionYKey) as? NSNumber {
            position.y = CGFloat(yValue.doubleValue)
        }
        if let zValue = dictionary.object(forKey: SMBarDisplayComponentBaseZKey) as? NSNumber {
            _baseZ = CGFloat(zValue.doubleValue)
        }
        
        
        // load sprites
        if let backgroundSpriteNameValue = dictionary.object(forKey: SMBarDisplayComponentBackgroundBarNameKey) as? String {
            backgroundBar = SKSpriteNode(imageNamed: backgroundSpriteNameValue)
        }
    }
    
    // MARK: - Bar alignment
    
    func updateBarAlignment() {
        
    }
    
    // MARK: - Text positioning / alignment
    
    func updateTextPosition() {
        
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
