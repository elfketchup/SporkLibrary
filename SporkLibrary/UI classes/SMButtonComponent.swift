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



class SMButtonComponent : SMObject {
    // MARK: - Instance variables

    // Current position
    var position = CGPoint(x: -100, y: -100)
    
    // Current Z-position; every other node is stacked on top of the "base" Z position in a certain order
    var baseZ = CGFloat(1)
    
    // A label that's either put on top of the existing buttons, or just exists on its own
    var labelNode : SMTextNode? = nil
    
    // Offset for the label (relative to the main button position)
    var labelOffset = CGPoint(x: 0, y: 0)
    
    // One "normal" sprite for when the button isn't pressed, and an optional sprite for when the button does get pressed.
    var buttonNormalSprite : SKSpriteNode? = nil
    var buttonPressedSprite : SKSpriteNode? = nil
    
    // Button colors
    var buttonNormalColor = UIColor.white
    var buttonPressedColor = UIColor.white
    var buttonInactiveColor = UIColor.lightGray
    var labelColor = UIColor.white
    
    // Used to identify a button
    var buttonTag = Int(0)      // identification by number
    var buttonID = ""           // identification by string
    
    // Used to know when the button is being touched
    var touchMovedHere = false
    var touchEndedHere = false
    
    // Determines if the button can be pressed or not (the button might not be "pressable" if the player isn't allowed to select it for some reason)
    var pressable = true
    
    // Determines if this will show as inactive (for example, the button might be "grayed out" if it can't be pressed)
    var showAsInactive = false
    
    /*
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
 */
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        // make sure no sprite data exists right now
        buttonNormalSprite = nil
        buttonPressedSprite = nil
        labelNode = nil
        
        // load identification data
        if let buttonTagFromDictionary = dictionary.object(forKey: SMButtonComponentButtonTagKey) as? NSNumber {
            buttonTag = buttonTagFromDictionary.intValue
        }
        if let buttonNameFromDictionary = dictionary.object(forKey: SMButtonComponentButtonNameKey) as? String {
            buttonID = buttonNameFromDictionary
        }
    
        // Load button color data
        buttonNormalColor = self.loadButtonColorsFromDictionary(dictionary: dictionary,
                                                                redKey: SMButtonComponentNormalButtonRedKey,
                                                                greenKey: SMButtonComponentNormalButtonGreenKey,
                                                                blueKey: SMButtonComponentNormalButtonBlueKey)
        buttonPressedColor = self.loadButtonColorsFromDictionary(dictionary: dictionary,
                                                                 redKey: SMButtonComponentPressedButtonRedKey,
                                                                 greenKey: SMButtonComponentPressedButtonGreenKey,
                                                                 blueKey: SMButtonComponentPressedButtonBlueKey)
        labelColor = self.loadButtonColorsFromDictionary(dictionary: dictionary,
                                                         redKey: SMButtonComponentLabelColorRedKey,
                                                         greenKey: SMButtonComponentLabelColorGreenKey,
                                                         blueKey: SMButtonComponentLabelColorBlueKey)
        buttonInactiveColor = self.loadButtonColorsFromDictionary(dictionary: dictionary,
                                                                  redKey: SMButtonComponentInactiveButtonRedKey,
                                                                  greenKey: SMButtonComponentInactiveButtonGreenKey,
                                                                  blueKey: SMButtonComponentInactiveButtonBlueKey,
                                                                  defaultColor: UIColor.lightGray) // use light gray as default inactive color
        
        // Attempt to load existing sprites first
        if let existingSpriteForNormalButton = dictionary.object(forKey: SMButtonComponentNormalSpriteNodeKey) as? SKSpriteNode {
            buttonNormalSprite = existingSpriteForNormalButton
        }
        if let existingSpriteForPressedButton = dictionary.object(forKey: SMButtonComponentPressedSpriteNodeKey) as? SKSpriteNode {
            buttonPressedSprite = existingSpriteForPressedButton
        }
        if let existingLabelNode = dictionary.object(forKey: SMButtonComponentLabelNodeKey) as? SMTextNode {
            labelNode = existingLabelNode
        }
        
        // Next try to load sprites from an image filename (but only if there's no existing sprite data)
        if let normalButtonSpriteName = dictionary.object(forKey: SMButtonComponentNormalSpriteNameKey) as? String {
            buttonNormalSprite = SKSpriteNode(imageNamed: normalButtonSpriteName)
        }
        if let pressedButtonSpriteName = dictionary.object(forKey: SMButtonComponentPressedSpriteNameKey) as? String {
            buttonPressedSprite = SKSpriteNode(imageNamed: pressedButtonSpriteName)
        }
        
        // Load label information
        if let labelTextInput = dictionary.object(forKey: SMButtonComponentLabelTextKey) as? String {
            labelNode = SMTextNode(text: labelTextInput)
        }
        if let labelOffsetX = dictionary.object(forKey: SMButtonComponentLabelOffsetXKey) as? NSNumber {
            labelOffset.x = CGFloat(labelOffsetX.doubleValue)
        }
        if let labelOffsetY = dictionary.object(forKey: SMButtonComponentLabelOffsetYKey) as? NSNumber {
            labelOffset.y = CGFloat(labelOffsetY.doubleValue)
        }
        
        // The following information only gets used if there's an existing label
        if labelNode != nil {
            if let labelFontInput = dictionary.object(forKey: SMButtonComponentLabelFontKey) as? String {
                labelNode!.fontName = labelFontInput
            }
            if let labelFontSize = dictionary.object(forKey: SMButtonComponentLabelSizeKey) as? NSNumber {
                labelNode!.fontSize = CGFloat(labelFontSize.doubleValue)
            }
        }
    }
    
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
    
    // MARK: - Sprite retrieval
    
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
    
    // MARK: - Touch input
    
    // Called during touchesMoved
    func touchMovedTo(point:CGPoint) {
        // check if this button can even be interacted with or not
        if pressable == true {
            if let theSprite = self.sprite() {
                position = theSprite.position
                
                if theSprite.frame.contains(point) {
                    touchMovedHere = true
                } else {
                    touchMovedHere = false
                }
            }
        } else {
            touchMovedHere = false
        }
    }
    
    func touchEndedAt(point:CGPoint) {
        if pressable == true {
            if let theSprite = self.sprite() {
                position = theSprite.position
                
                if theSprite.frame.contains(point) {
                    touchEndedHere = true
                } else {
                    touchEndedHere = false
                }
            }
        } else {
            touchEndedHere = false
        }
    }
}
