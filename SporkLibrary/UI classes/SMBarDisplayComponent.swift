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
let SMBarDisplayComponentBarSpriteNodeKey       = "bar sprite node" // SKSpriteNode, reference to existing sprite node
let SMBarDisplayComponentBackgroundBarNodeKey   = "background node" // SKSpriteNode, reference to existing sprite node for background bar
let SMBarDisplayComponentLabelTextKey           = "label text"      // String, text for label node displayed over bar
let SMBarDisplayComponentLabelDictionaryKey     = "label info"      // NSDictionary, loads SMTextNode object
let SMBarDisplayComponentLabelNodeKey           = "label node"      // SMTextNode, reference to existing label

// String values for bar alignment
let SMBarDisplayComponentAlignmentStringLeft    = "left"
let SMBarDisplayComponentAlignmentStringRight   = "right"
let SMBarDisplayComponentAlignmentStringCenter  = "center"

// Text position values as strings
let SMBarDisplayComponentTextPositionStringCenter   = "center"
let SMBarDisplayComponentTextPositionStringAbove    = "above"
let SMBarDisplayComponentTextPositionStringBelow    = "below"
let SMBarDisplayComponentTextPositionStringLeft     = "left"
let SMBarDisplayComponentTextPositionStringRight    = "right"

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
    
    private var originalWidthOfBarSprite = CGFloat(1.0)
    
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
        setBarSpriteNode(sprite: sprite)
        
        _baseZ = sprite.zPosition
        _position = sprite.position
        updateZPositions()
        updateBarDisplay()
    }
    
    init(sprite:SKSpriteNode, backgroundSprite:SKSpriteNode) {
        super.init()
        //barSprite = sprite
        setBarSpriteNode(sprite: sprite)
        backgroundBar = backgroundSprite
        
        _position = sprite.position
        _baseZ = backgroundSprite.zPosition
        updateZPositions()
        updateBarDisplay()
    }
    
    init(labelText:String, sprite:SKSpriteNode, backgroundSprite:SKSpriteNode) {
        super.init()
        //barSprite = sprite
        setBarSpriteNode(sprite: sprite)
        backgroundBar = backgroundSprite
        setLabelText(string: labelText)
        
        _position = sprite.position
        _baseZ = backgroundSprite.zPosition
        updateZPositions()
        updateBarDisplay()
    }
    
    init(barSpriteName:String) {
        super.init()
        let sprite = SKSpriteNode(imageNamed: barSpriteName)
        setBarSpriteNode(sprite: sprite)
        
        updateZPositions()
        updateBarDisplay()
    }
    
    init(barSpriteName:String, backgroundBarName:String) {
        super.init()
        let sprite = SKSpriteNode(imageNamed: barSpriteName)
        setBarSpriteNode(sprite: sprite)
        backgroundBar = SKSpriteNode(imageNamed: backgroundBarName)
        
        updateZPositions()
        updateBarDisplay()
    }
    
    init(labelText:String, barSpriteName:String, backgroundBarName:String) {
        super.init()
        let sprite = SKSpriteNode(imageNamed: barSpriteName)
        setBarSpriteNode(sprite: sprite)
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
    
    // MARK: - De-init
    
    override func willBeRemovedFromParent() {
        self.removeFromParentNode()
        
        barSprite = nil
        backgroundBar = nil
        labelNode = nil
        
        super.willBeRemovedFromParent()
    }
    
    // MARK: - Dictionary loading

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
        
        // get alignments
        if let barAlignmentValue = dictionary.object(forKey: SMBarDisplayComponentBarAlignmentKey) as? String {
            _barAlignment = self.barAlignmentFromString(string: barAlignmentValue)
        }
        
        if let textPositionValue = dictionary.object(forKey: SMBarDisplayComponentTextAlignmentKey) as? String {
            _textAlignment = self.barTextPositionFromString(string: textPositionValue)
        }
        
        
        // load sprites
        if let backgroundSpriteNameValue = dictionary.object(forKey: SMBarDisplayComponentBackgroundBarNameKey) as? String {
            backgroundBar = SKSpriteNode(imageNamed: backgroundSpriteNameValue)
        }
        if let barSpriteNameValue = dictionary.object(forKey: SMBarDisplayComponentBarSpriteNameKey) as? String {
            let sprite = SKSpriteNode(imageNamed: barSpriteNameValue)
            setBarSpriteNode(sprite: sprite)
        }
        if let backgroundSpriteNodeValue = dictionary.object(forKey: SMBarDisplayComponentBackgroundBarNodeKey) as? SKSpriteNode {
            backgroundBar = backgroundSpriteNodeValue
        }
        if let barSpriteNodeValue = dictionary.object(forKey: SMBarDisplayComponentBarSpriteNodeKey) as? SKSpriteNode {
            //barSprite = barSpriteNodeValue
            setBarSpriteNode(sprite: barSpriteNodeValue)
        }
        
        // get label data
        if let labelTextValue = dictionary.object(forKey: SMBarDisplayComponentLabelTextKey) as? String {
            labelNode = SMTextNode(text: labelTextValue)
        }
        if let labelDictionaryValue = dictionary.object(forKey: SMBarDisplayComponentLabelDictionaryKey) as? NSDictionary {
            labelNode = SMTextNode(dictionary: labelDictionaryValue)
        }
        if let labelNodeValue = dictionary.object(forKey: SMBarDisplayComponentLabelNodeKey) as? SMTextNode {
            labelNode = labelNodeValue
        }
    }

    func barTextPositionFromString(string:String) -> SMBarDisplayComponentTextPosition {
        if SMStringsAreSame(first: string, second: SMBarDisplayComponentTextPositionStringAbove) {
            return .Above
        } else if SMStringsAreSame(first: string, second: SMBarDisplayComponentTextPositionStringBelow) {
            return .Below
        } else if SMStringsAreSame(first: string, second: SMBarDisplayComponentTextPositionStringLeft) {
            return .Left
        } else if SMStringsAreSame(first: string, second: SMBarDisplayComponentTextPositionStringRight) {
            return .Right
        }
        
        return .Center
    }
    
    func barAlignmentFromString(string:String) -> SMBarDisplayComponentAlignment {
        if SMStringsAreSame(first: string, second: SMBarDisplayComponentAlignmentStringLeft) {
            return .Left
        } else if SMStringsAreSame(first: string, second: SMBarDisplayComponentAlignmentStringRight) {
            return .Right
        }
        
        return .Center
    }
    
    // MARK: - Sprite functions
    
    func addToNode(node:SKNode) {
        if backgroundBar != nil {
            node.addChild(backgroundBar!)
        }
        if barSprite != nil {
            node.addChild(barSprite!)
        }
        if labelNode != nil {
            node.addChild(labelNode!)
        }
    }
    
    func removeFromParentNode() {
        if backgroundBar != nil {
            backgroundBar!.removeAllActions()
            backgroundBar!.removeFromParent()
        }
        if barSprite != nil {
            barSprite!.removeAllActions()
            barSprite!.removeFromParent()
        }
        if labelNode != nil {
            labelNode!.removeAllActions()
            labelNode!.removeFromParent()
        }
    }
    
    func setBarSpriteNode(sprite:SKSpriteNode) {
        originalWidthOfBarSprite = sprite.frame.size.width
        barSprite = sprite
    }
    
    // MARK: - Bar alignment
    
    func updateBarAlignment() {
        if barSprite == nil {
            return
        }
        
        barSprite!.xScale = _length
        
        switch(_barAlignment) {
        case .Right:
            let positionX = (_position.x + (originalWidthOfBarSprite * 0.5)) - (barSprite!.frame.size.width * 0.5)
            let positionY = _position.y
            
            barSprite!.position = CGPoint(x: positionX, y: positionY)
            
        case .Left:
            let positionX = (_position.x - (originalWidthOfBarSprite * 0.5)) + (barSprite!.frame.size.width * 0.5)
            let positionY = _position.y

            barSprite!.position = CGPoint(x: positionX, y: positionY)
            
        default: // center
            barSprite!.position = _position
        }
    }
    
    // MARK: - Text positioning / alignment
    
    func updateTextPosition() {
        if barSprite == nil || labelNode == nil {
            return
        }
        
        switch(_textAlignment) {
        case .Above:
            if backgroundBar != nil {
                labelNode!.offsetSprite = backgroundBar
            } else {
                labelNode!.offsetSprite = barSprite
            }
            labelNode!.offsetFromSpriteType = .AboveSprite
            labelNode!.updateOffsets()
            
        case .Below:
            if backgroundBar != nil {
                labelNode!.offsetSprite = backgroundBar
            } else {
                labelNode!.offsetSprite = barSprite
            }
            labelNode!.offsetFromSpriteType = .BelowSprite
            labelNode!.updateOffsets()
            
        case .Left:
            labelNode!.offsetSprite = nil
            labelNode!.offsetFromSpriteType = .CenteredOnSprite
            
            let textX = _position.x - (originalWidthOfBarSprite * 0.5) + (labelNode!.frame.size.width * 0.5)
            let textY = _position.y
            
            labelNode!.position = CGPoint(x: textX, y: textY)
            
        case .Right:
            labelNode!.offsetSprite = nil
            labelNode!.offsetFromSpriteType = .CenteredOnSprite
            
            let textX = _position.x + (originalWidthOfBarSprite * 0.5) - (labelNode!.frame.size.width * 0.5)
            let textY = _position.y
            
            labelNode!.position = CGPoint(x: textX, y: textY)
            
        default: // center
            labelNode!.position = _position
        }
    }
 
    // MARK: - Label functions
    
    func setLabelText(string:String) {
        if labelNode == nil {
            labelNode = SMTextNode(text: string)
        } else {
            labelNode!.text = string
        }
        
        updateTextPosition()
    }
    
    // MARK: - Sprite positions
    
    func parentNode() -> SKNode? {
        if barSprite != nil {
            return barSprite!.parent
        }
        
        return nil
    }
    
    func updateZPositions() {
        var zForNode = _baseZ
        
        if backgroundBar != nil {
            backgroundBar!.zPosition = zForNode
            zForNode += 1.0
        }
        
        if barSprite != nil {
            barSprite!.zPosition = zForNode
            zForNode += 1.0
        }
        
        if labelNode != nil {
            labelNode!.zPosition = zForNode
        }
    }
    
    func updatePositions() {
        if barSprite != nil {
            barSprite!.position = _position
        }
        if backgroundBar != nil {
            backgroundBar!.position = _position
        }
        
        self.updateZPositions()
        self.updateBarAlignment()
        self.updateTextPosition()
    }
    
    func updateBarDisplay() {
        self.updatePositions()
    }
}


func SMBarDisplayComponentFromEntity(entity:SMObject) -> SMBarDisplayComponent? {
    if let component = entity.objectOfType(ofType: SMBarDisplayComponent.self) as? SMBarDisplayComponent {
        return component
    }
    
    return nil
}
