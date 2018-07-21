//
//  SMButtonComponent.swift
//  SporkLibrary
//
//  Created by James on 7/9/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// MARK: - Dictionary keys
let SMButtonComponentLabelTextKey           = "label text"              // string, text for label
let SMButtonComponentLabelFontKey           = "label font"              // string, font for label
let SMButtonComponentLabelSizeKey           = "label size"              // string, size of label text/font
let SMButtonComponentLabelOffsetXKey        = "label offset x"          // CGFloat, x offset for label (from center)
let SMButtonComponentLabelOffsetYKey        = "label offset y"          // CGFloat, y offset for label (from center)
let SMButtonComponentLabelNodeKey           = "label node"              // SMTextNode, reference to existing node
let SMButtonComponentNormalSpriteNameKey    = "normal sprite name"      // string, filename for "normal" sprite
let SMButtonComponentPressedSpriteNameKey   = "pressed sprite name"     // string, filename for pressed-down / touched sprite
let SMButtonComponentNormalSpriteNodeKey    = "normal sprite node"      // SKSpriteNode, reference to existing sprite node
let SMButtonComponentPressedSpriteNodeKey   = "pressed sprite node"     // SKSpriteNode, reference to existing sprite node
let SMButtonComponentPositionXKey           = "x"                       // CGFloat, x position of button
let SMButtonComponentPositionYKey           = "y"                       // CGFloat, y position of button
let SMButtonComponentButtonTagKey           = "button tag"              // Integer, tag ID
let SMButtonComponentButtonNameKey          = "button name"             // String, identify button by name
let SMButtonComponentIsPressableKey         = "pressable"               // Bool, determines if the button can be pressed at this time
let SMButtonComponentShowAsInactiveKey      = "show as inactive"        // Bool, 'true' means this would be shown as inactive (grayed-out) when it can't be pressed
let SMButtonComponentLabelOffsetStyleKey    = "label offset style"      // String, can be "left" "right" "above" "below" or "center"

// Dictionary color keys
let SMButtonComponentNormalButtonRedKey     = "normal r"    // Double, 0.0 - 1.0, defined red color in RGB (for normal button)
let SMButtonComponentNormalButtonGreenKey   = "normal g"    // Double, defines green color in RGB (for normal button)
let SMButtonComponentNormalButtonBlueKey    = "normal b"    // Double, defines blue color (for normal button)
let SMButtonComponentPressedButtonRedKey    = "pressed r"   // Double, defines red color for pressed button
let SMButtonComponentPressedButtonGreenKey  = "pressed g"   // Double, defines green color for pressed button
let SMButtonComponentPressedButtonBlueKey   = "pressed b"   // Double, defines blue color for pressed button
let SMButtonComponentLabelColorRedKey       = "label r"     // Double, red color for label
let SMButtonComponentLabelColorGreenKey     = "label g"     // Double, green color for label
let SMButtonComponentLabelColorBlueKey      = "label b"     // Double, blue color for label
let SMButtonComponentInactiveButtonRedKey   = "inactive r"  // Double, red color for inactive button
let SMButtonComponentInactiveButtonGreenKey = "inactive g"  // Double, green color for inactive button
let SMButtonComponentInactiveButtonBlueKey  = "inactive b"  // Double, blue color for inactive button

// Dictionary input strings
let SMButtonComponentLabelOffsetStyleBelowString    = "below"
let SMButtonComponentLabelOffsetStyleLeftString     = "left"
let SMButtonComponentLabelOffsetStyleCenterString   = "center"
let SMButtonComponentLabelOffsetStyleRightString    = "right"
let SMButtonComponentLabelOffsetStyleAboveString    = "above"


// MARK: - Enumeration

enum SMButtonComponentLabelOffsetStyle : Int8 {
    case Center     = 0     // Label is in center of button sprite
    case Left       = 1     // Label is to left of button sprite
    case Right      = 2     // Label is to right of button sprite
    case Below      = 3     // label is below the button sprite
    case Above      = 4     // Label is above button sprite
}



class SMButtonComponent : SMObject {
    // MARK: - Instance variables
    
    // Level - this is used by SMButtonManager to keep track of differenet "levels" of button input
    var level = 0 // 0 is always accessible to SMButtonManager

    // Current position
    var _position = CGPoint(x: -500, y: -500) // default is far offscreen
    var position : CGPoint {
        get {
            return _position
        }
        set(point) {
            _position.x = point.x
            _position.y = point.y
            
            updatePositions()
        }
    }
    
    
    // Current Z-position; every other node is stacked on top of the "base" Z position in a certain order
    var _baseZ = CGFloat(1)
    var zPosition : CGFloat {
        get {
            return _baseZ
        }
        set(z) {
            _baseZ = z
            updateZPositions()
        }
    }
    
    // A label that's either put on top of the existing buttons, or just exists on its own
    var labelNode : SMTextNode? = nil
    
    // Offset for the label (relative to the main button position)
    var _labelOffset = CGPoint(x: 0, y: 0)
    var labelOffset : CGPoint {
        get {
            return _labelOffset
        }
        set(offset) {
            _labelOffset = offset
            updateZPositions()
            updatePositions()
        }
    }
    
    // Used to calculate where the label is in relation to the button sprite
    var _labelOffsetStyle = SMButtonComponentLabelOffsetStyle.Center
    var labelOffsetStyle : SMButtonComponentLabelOffsetStyle {
        get {
            return _labelOffsetStyle
        }
        set (style) {
            _labelOffsetStyle = style
            updatePositions()
            //updateLabelOffsetStyle()
        }
    }
    
    // One "normal" sprite for when the button isn't pressed, and an optional sprite for when the button does get pressed.
    var buttonNormalSprite : SKSpriteNode? = nil
    var buttonPressedSprite : SKSpriteNode? = nil
    
    // Button colors
    var _buttonNormalColor = UIColor.white
    var _buttonPressedColor = UIColor.white
    var _buttonInactiveColor = UIColor.lightGray
    var _labelColor = UIColor.white
    
    var buttonNormalColor : UIColor {
        get {
            return _buttonNormalColor
        }
        set(color) {
            _buttonNormalColor = color
            updateColors()
        }
    }
    var buttonPressedColor : UIColor {
        get {
            return _buttonPressedColor
        }
        set(color) {
            _buttonPressedColor = color
            updateColors()
        }
    }
    var buttonInactiveColor : UIColor {
        get {
            return _buttonInactiveColor
        }
        set(color) {
            _buttonInactiveColor = color
            updateColors()
        }
    }
    var labelColor : UIColor {
        get{
            return _labelColor
        }
        set(color) {
            _labelColor = color
            updateColors()
        }
    }
    
    // Used to identify a button
    var buttonTag = "" // identification by string
    
    // Used to know when the button is being touched
    var touchMovedHere = false
    var touchEndedHere = false
    var isBeingTouched = false
    
    // Determines if the button can be pressed or not (the button might not be "pressable" if the player isn't allowed to select it for some reason)
    var pressable = true
    
    // Determines if this will show as inactive (for example, the button might be "grayed out" if it can't be pressed)
    var showAsInactiveWhenNotPressable = false
    
    // MARK: - Initializers
    
    override init(withDictionary: NSDictionary) {
        super.init()
        self.loadFromDictionary(dictionary: withDictionary)
        
        self.updateZPositions()
        self.updatePositions()
        self.updateColors()
    }
    
    init(withSpriteNode:SKSpriteNode) {
        super.init()
        buttonNormalSprite = withSpriteNode
        _position = withSpriteNode.position
        
        self.updateZPositions()
        self.updatePositions()
        self.updateColors()
    }
    
    init(withSpriteNode:SKSpriteNode, andLabelText:String) {
        super.init()
        buttonNormalSprite = withSpriteNode
        labelNode = SMTextNode(text: andLabelText)
        _position = withSpriteNode.position
        
        self.updateZPositions()
        self.updatePositions()
        self.updateColors()
    }
    
    init(withSpriteNode:SKSpriteNode, andButtonPressedSprite:SKSpriteNode) {
        super.init()
        buttonNormalSprite = withSpriteNode
        buttonPressedSprite = andButtonPressedSprite
        buttonPressedSprite!.alpha = 0
        _position = withSpriteNode.position
        
        self.updateZPositions()
        self.updatePositions()
        self.updateColors()
    }
    
    init(withLabelNode:SMTextNode, andSpriteNode:SKSpriteNode) {
        super.init()
        labelNode = withLabelNode
        buttonNormalSprite = andSpriteNode
        
        self.updateZPositions()
        self.updatePositions()
        self.updateColors()
    }
    
    init(withLabelNode:SMTextNode, andSpriteNode:SKSpriteNode, andButtonPressedNode:SKSpriteNode) {
        super.init()
        //labelNode = SMTextNode(text: withLabelText)
        labelNode = withLabelNode
        buttonNormalSprite = andSpriteNode
        buttonPressedSprite = andButtonPressedNode
        buttonPressedSprite!.alpha = 0
        _position = andSpriteNode.position
        
        self.updateZPositions()
        self.updatePositions()
        self.updateColors()
    }
    
    init(withLabelText:String) {
        super.init()
        labelNode = SMTextNode(text: withLabelText)
        labelNode!.position = position
        
        self.updateZPositions()
        self.updatePositions()
        self.updateColors()
    }
    
    // MARK: - Dictionary loading
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        // make sure no sprite data exists right now
        buttonNormalSprite = nil
        buttonPressedSprite = nil
        labelNode = nil
        
        // Load position data
        if let positionX = dictionary.object(forKey: SMButtonComponentPositionXKey) as? NSNumber {
            _position.x = CGFloat(positionX.doubleValue)
        }
        if let positionY = dictionary.object(forKey: SMButtonComponentPositionYKey) as? NSNumber {
            _position.y = CGFloat(positionY.doubleValue)
        }
        
        // load identification data
        if let buttonTagFromDictionary = dictionary.object(forKey: SMButtonComponentButtonTagKey) as? String {
            buttonTag = buttonTagFromDictionary
        }
    
        // Load button color data
        _buttonNormalColor = self.loadButtonColorsFromDictionary(dictionary: dictionary,
                                                                redKey: SMButtonComponentNormalButtonRedKey,
                                                                greenKey: SMButtonComponentNormalButtonGreenKey,
                                                                blueKey: SMButtonComponentNormalButtonBlueKey)
        _buttonPressedColor = self.loadButtonColorsFromDictionary(dictionary: dictionary,
                                                                 redKey: SMButtonComponentPressedButtonRedKey,
                                                                 greenKey: SMButtonComponentPressedButtonGreenKey,
                                                                 blueKey: SMButtonComponentPressedButtonBlueKey)
        _labelColor = self.loadButtonColorsFromDictionary(dictionary: dictionary,
                                                         redKey: SMButtonComponentLabelColorRedKey,
                                                         greenKey: SMButtonComponentLabelColorGreenKey,
                                                         blueKey: SMButtonComponentLabelColorBlueKey)
        _buttonInactiveColor = self.loadButtonColorsFromDictionary(dictionary: dictionary,
                                                                  redKey: SMButtonComponentInactiveButtonRedKey,
                                                                  greenKey: SMButtonComponentInactiveButtonGreenKey,
                                                                  blueKey: SMButtonComponentInactiveButtonBlueKey,
                                                                  defaultColor: UIColor.lightGray) // use light gray as default inactive color
        
        // Attempt to load existing sprites first
        if let existingSpriteForNormalButton = dictionary.object(forKey: SMButtonComponentNormalSpriteNodeKey) as? SKSpriteNode {
            buttonNormalSprite = existingSpriteForNormalButton
            _position = existingSpriteForNormalButton.position
        }
        if let existingSpriteForPressedButton = dictionary.object(forKey: SMButtonComponentPressedSpriteNodeKey) as? SKSpriteNode {
            buttonPressedSprite = existingSpriteForPressedButton
            buttonPressedSprite!.alpha = 0
            buttonPressedSprite!.position = _position
        }
        if let existingLabelNode = dictionary.object(forKey: SMButtonComponentLabelNodeKey) as? SMTextNode {
            labelNode = existingLabelNode
            labelNode!.position = _position
        }
        
        // Next try to load sprites from an image filename (but only if there's no existing sprite data)
        if let normalButtonSpriteName = dictionary.object(forKey: SMButtonComponentNormalSpriteNameKey) as? String {
            buttonNormalSprite = SKSpriteNode(imageNamed: normalButtonSpriteName)
            buttonNormalSprite!.position = _position
        }
        if let pressedButtonSpriteName = dictionary.object(forKey: SMButtonComponentPressedSpriteNameKey) as? String {
            buttonPressedSprite = SKSpriteNode(imageNamed: pressedButtonSpriteName)
            buttonPressedSprite!.alpha = 0
            buttonPressedSprite!.position = _position
        }
        
        // Load label information
        if let labelTextInput = dictionary.object(forKey: SMButtonComponentLabelTextKey) as? String {
            labelNode = SMTextNode(text: labelTextInput)
            labelNode!.position = _position
        }
        if let labelOffsetX = dictionary.object(forKey: SMButtonComponentLabelOffsetXKey) as? NSNumber {
            _labelOffset.x = CGFloat(labelOffsetX.doubleValue)
        }
        if let labelOffsetY = dictionary.object(forKey: SMButtonComponentLabelOffsetYKey) as? NSNumber {
            _labelOffset.y = CGFloat(labelOffsetY.doubleValue)
        }
        if let labelFontInput = dictionary.object(forKey: SMButtonComponentLabelFontKey) as? String {
            self.setLabelFont(fontName: labelFontInput)
        }
        if let labelFontSize = dictionary.object(forKey: SMButtonComponentLabelSizeKey) as? NSNumber {
            self.setLabelFontSize(size: CGFloat(labelFontSize.doubleValue) )
        }
        
        // Load data about inactive / pressable states
        if let pressableFlag = dictionary.object(forKey: SMButtonComponentIsPressableKey) as? NSNumber {
            pressable = pressableFlag.boolValue
        }
        if let showAsInactiveFlag = dictionary.object(forKey: SMButtonComponentShowAsInactiveKey) as? NSNumber {
            showAsInactiveWhenNotPressable = showAsInactiveFlag.boolValue
        }
        
        // Check for a label style (uses center by default)
        if let labelOffsetStyleString = dictionary.object(forKey: SMButtonComponentLabelOffsetStyleKey) as? String {
            if SMStringsAreSame(first: labelOffsetStyleString, second: SMButtonComponentLabelOffsetStyleLeftString) {
                labelOffsetStyle = .Left
            } else if SMStringsAreSame(first: labelOffsetStyleString, second: SMButtonComponentLabelOffsetStyleAboveString) {
                labelOffsetStyle = .Above
            } else if SMStringsAreSame(first: labelOffsetStyleString, second: SMButtonComponentLabelOffsetStyleBelowString) {
                labelOffsetStyle = .Below
            } else if SMStringsAreSame(first: labelOffsetStyleString, second: SMButtonComponentLabelOffsetStyleRightString) {
                labelOffsetStyle = .Right
            } else {
                labelOffsetStyle = .Center
            }
        }
    }
    
    // MARK: - Color
    
    func loadButtonColorsFromDictionary(dictionary:NSDictionary, redKey:String, greenKey:String, blueKey:String) -> UIColor {
        return self.loadButtonColorsFromDictionary(dictionary: dictionary, redKey: redKey, greenKey: greenKey, blueKey: blueKey, defaultColor: UIColor.white)
    }
    
    func loadButtonColorsFromDictionary(dictionary:NSDictionary, redKey:String, greenKey:String, blueKey:String, defaultColor:UIColor) -> UIColor {
        var customColorUsed = false
        var r = CGFloat(1.0)
        var g = CGFloat(1.0)
        var b = CGFloat(1.0)
        
        if let colorR = dictionary.object(forKey: redKey) as? NSNumber {
            customColorUsed = true
            r = CGFloat(colorR.doubleValue)
        }
        if let colorG = dictionary.object(forKey: greenKey) as? NSNumber {
            customColorUsed = true
            g = CGFloat(colorG.doubleValue)
        }
        if let colorB = dictionary.object(forKey: blueKey) as? NSNumber {
            customColorUsed = true
            b = CGFloat(colorB.doubleValue)
        }
        
        // if no values were loaded, then just return white by default
        if customColorUsed == false {
            return defaultColor
        }
        
        r = SMClampFloat(input: r, min: 0, max: 1.0)
        g = SMClampFloat(input: g, min: 0, max: 1.0)
        b = SMClampFloat(input: b, min: 0, max: 1.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    // MARK: - Identification
    
    func isTagged(string:String) -> Bool {
        if SMStringLength(string: buttonTag) < 1 {
            return false
        }
        
        return SMStringsAreSame(first: buttonTag, second: string)
    }
    
    func textOfButtonLabel() -> String? {
        if labelNode == nil {
            return nil
        }
        
        return labelNode!.text
    }
    
    // MARK: - Label functions
    
    func setLabelFont(fontName:String) {
        if labelNode != nil {
            labelNode!.fontName = fontName
        }
    }
    
    func setLabelText(text:String) {
        if labelNode != nil {
            labelNode!.text = text
        }
    }
    
    func setLabelFontSize(size:CGFloat) {
        if labelNode != nil {
            labelNode!.fontSize = size
        }
    }
    
    // MARK: - Positions

    
    // Ensure that the different nodes have their Z-positions arranged properly
    func updateZPositions() {
        var zToUse = _baseZ // uses "base" Z as starting point
        
        if buttonNormalSprite != nil {
            buttonNormalSprite!.zPosition = zToUse
            zToUse += 1.0
        }
        
        if buttonPressedSprite != nil {
            buttonPressedSprite!.zPosition = zToUse
            zToUse += 1.0
        }
        
        if labelNode != nil {
            labelNode!.zPosition = zToUse
            zToUse += 1.0
        }
    }
    
    func updatePositions() {
        if buttonNormalSprite != nil {
            buttonNormalSprite!.position = _position
        }
        
        if buttonPressedSprite != nil {
            buttonPressedSprite!.position = _position
        }
        
        self.updateZPositions()
        self.updateLabelOffsetStylePosition()
    }
    
    func setZPosition(z:CGFloat) {
        _baseZ = z
        //self.updatePositions()
        self.updateZPositions()
    }
    
    func updateLabelOffsetStylePosition() {
        if labelNode == nil {
            return
        }
        
        // check if this "button" is label-only and there's no other sprite data
        if buttonNormalSprite == nil && buttonPressedSprite == nil {
            labelNode!.position = _position
            return
        }
        
        var buttonSize = labelNode!.frame.size
        //var origin = labelNode!.position
        let halfWidthOfLabel = labelNode!.frame.size.height * 0.5
        let halfHeightOfLabel = labelNode!.frame.size.width * 0.5
        
        if buttonNormalSprite != nil {
            buttonSize = buttonNormalSprite!.frame.size
            //origin = buttonNormalSprite!.position
        } else {
            buttonSize = buttonPressedSprite!.frame.size
            //origin = buttonPressedSprite!.position
        }
        
        var basePosition = _position // this is where the offset will be calculate from... by default this matches the "center" offset style
        let halfHeightOfButton = (buttonSize.height * 0.5)
        let halfWidthOfButton = (buttonSize.width * 0.5)
        
        switch(_labelOffsetStyle) {
            
        case .Above:
            basePosition.y = _position.y + halfHeightOfButton + halfHeightOfLabel
            
        case .Below:
            basePosition.y = _position.y - halfHeightOfButton - halfHeightOfLabel
            
        case .Left:
            basePosition.x = _position.x - halfWidthOfButton - halfWidthOfLabel
            
        case .Right:
            basePosition.x = _position.x + halfWidthOfButton + halfWidthOfLabel
            
        default:
            basePosition = _position
        }
        
        labelNode!.position = SMPositionAddTwoPositions(first: basePosition, second: _labelOffset)
    }
    
    // MARK: - Color functions
    
    func updateColors() {
        // check if this button should show as inactive
        if pressable == false && showAsInactiveWhenNotPressable == true {
            if buttonPressedSprite != nil {
                buttonPressedSprite!.colorBlendFactor = 1.0
                buttonPressedSprite!.color = _buttonInactiveColor
            }
            if buttonNormalSprite != nil {
                buttonNormalSprite!.colorBlendFactor = 1.0
                buttonNormalSprite!.color = _buttonInactiveColor
            }
            
            return
        }
        
        // The "pressed button sprite" always has the same color
        if buttonPressedSprite != nil {
            buttonPressedSprite!.colorBlendFactor = 1.0
            buttonPressedSprite!.color = _buttonPressedColor
            
            if isBeingTouched == true {
                buttonPressedSprite!.alpha = 1.0
            } else {
                buttonPressedSprite!.alpha = 0.0
            }
        }
        
        // The "normal button sprite" might have a normal color, or it might use the "button pressed" color if there's no special "button pressed sprite"
        if buttonNormalSprite != nil {
            if isBeingTouched == true {
                if buttonPressedSprite == nil { // no "button pressed sprite" exists, change the normal sprite's color
                    buttonNormalSprite!.colorBlendFactor = 1.0
                    buttonNormalSprite!.color = _buttonPressedColor
                } else {
                    buttonNormalSprite!.colorBlendFactor = 1.0
                    buttonNormalSprite!.color = _buttonNormalColor
                }
            } else {
                buttonNormalSprite!.colorBlendFactor = 1.0
                buttonNormalSprite!.color = _buttonNormalColor
            }
        }
    }
    
    // MARK: - Sprite functions
    
    func addToNode(node:SKNode) {
        if buttonNormalSprite != nil {
            node.addChild(buttonNormalSprite!)
        }
        if buttonPressedSprite != nil {
            node.addChild(buttonPressedSprite!)
        }
        if labelNode != nil {
            node.addChild(labelNode!)
        }
    }
    
    func removeFromParentNode() {
        if buttonNormalSprite != nil {
            buttonNormalSprite!.removeAllActions()
            buttonNormalSprite!.removeFromParent()
        }
        if buttonPressedSprite != nil {
            buttonPressedSprite!.removeAllActions()
            buttonPressedSprite!.removeFromParent()
        }
        if labelNode != nil {
            labelNode!.removeAllActions()
            labelNode!.removeFromParent()
        }
    }
    
    func sprite() -> SKSpriteNode? {
        if buttonNormalSprite != nil {
            return buttonNormalSprite
        }
        
        if parent != nil {
            if let spriteComponent = parent!.objectOfType(ofType: SMSpriteComponent.self) as? SMSpriteComponent {
                if spriteComponent.sprite != nil {
                    buttonNormalSprite = spriteComponent.sprite
                    return buttonNormalSprite
                }
            }
        }
        
        return nil
    }
    
    func buttonContainsPoint(point:CGPoint) -> Bool {
        if let theSprite = self.sprite() {
            if theSprite.frame.contains(point) {
                return true
            }
        }
        
        if buttonPressedSprite != nil {
            if buttonPressedSprite!.frame.contains(point) {
                return true
            }
        }
        
        if labelNode != nil {
            if labelNode!.frame.contains(point) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Touch input
    
    // called during touchesBegan
    func touchBeganAt(point:CGPoint) {
        let wasBeingTouched = isBeingTouched
        
        if pressable == true {
            if self.buttonContainsPoint(point: point) {
                isBeingTouched = true
            } else {
                isBeingTouched = false
            }
        } else {
            isBeingTouched = false
        }
        
        // Only update colors if the button status has changed
        if wasBeingTouched == false && isBeingTouched == true {
            self.updateColors()
        }
        if wasBeingTouched == true && isBeingTouched == false {
            self.updateColors()
        }
    }
    
    // Called during touchesMoved
    func touchMovedTo(point:CGPoint) {
        let wasBeingTouched = isBeingTouched
        
        // check if this button can even be interacted with or not
        if pressable == true {
            if self.buttonContainsPoint(point: point) {
                touchMovedHere = true
                isBeingTouched = true
            } else {
                touchMovedHere = false
                isBeingTouched = false
            }
        } else {
            touchMovedHere = false
            isBeingTouched = false
        }
        
        // Only update colors if the button status has changed
        if wasBeingTouched == false && isBeingTouched == true {
            self.updateColors()
        }
        if wasBeingTouched == true && isBeingTouched == false {
            self.updateColors()
        }
    }
    
    // called during touchesEnded
    func touchEndedAt(point:CGPoint) {
        let wasBeingTouched = isBeingTouched
        
        if pressable == true {
            if self.buttonContainsPoint(point: point) {
                touchEndedHere = true
                isBeingTouched = false
                
                self.updateColors()
            } else {
                touchEndedHere = false
                isBeingTouched = false
            }
        } else {
            touchEndedHere = false
            isBeingTouched = false
        }
        
        // Only update colors if the button status has changed
        if wasBeingTouched == false && isBeingTouched == true {
            self.updateColors()
        }
        if wasBeingTouched == true && isBeingTouched == false {
            self.updateColors()
        }
    }
    
    /*
    override func update(deltaTime: Double) {
        super.update(deltaTime: deltaTime)
    }*/
}

// MARK: - Utility functions

func SMButtonComponentFromEntity(entity:SMObject) -> SMButtonComponent? {
    return entity.objectOfType(ofType: SMButtonComponent.self) as? SMButtonComponent
}
