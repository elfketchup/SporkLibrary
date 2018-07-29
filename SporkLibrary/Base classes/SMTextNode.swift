//
//  SMTextNode.swift
//  SporkLibrary
//
//  Created by James on 6/20/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

let SMTextNodeMinimumFontSizeAllowed    = CGFloat( 1.0 )
let SMTextNodeDefaultFontName           = "Helvetica"
let SMTextNodeDefaultParagraphHeight    = CGFloat( 320.0 )

// For when SMTextNode is used as a label for a sprite (such as text on a button, a health percentage display on a health bar, etc).
// This determines where the text appears, relative to the sprite.
enum SMTextNodeOffsetFromSpriteType : Int8 {
    case CenteredOnSprite       = 0
    case BelowSprite            = 1
    case AboveSprite            = 2
    case LeftOfSprite           = 3
    case RightOfSprite          = 4
}

/*
 SMTextNode
 
 A better version of SKLabelNode, this can span multiple lines.
 */
class SMTextNode : SKSpriteNode {
    
    // MARK: - Instance variables
    
    private var _fontColor:UIColor          = UIColor.white
    private var _fontName                   = "Helvetica"
    private var _fontSize                   = CGFloat(16)
    private var _horizontalAlignmentMode    = SKLabelHorizontalAlignmentMode.center
    private var _verticalAlignmentMode      = SKLabelVerticalAlignmentMode.baseline
    private var _text                       = ""
    private var _paragraphWidth             = CGFloat(0)
    private var _offsetFromOrigin           = CGPoint(x: 0, y: 0)
    
    // used for offsets from sprite
    private var _offsetFromSpriteType       = SMTextNodeOffsetFromSpriteType.CenteredOnSprite
    private var _offsetSprite:SKSpriteNode? = nil
    
    // MARK: - Getter/setter methods
    
    var offsetFromOrigin : CGPoint {
        get {
            return _offsetFromOrigin
        }
        set(value) {
            _offsetFromOrigin = value
            updateOffsets()
        }
    }
    
    var offsetSprite : SKSpriteNode? {
        get {
            return _offsetSprite
        }
        set(sprite) {
            _offsetSprite = sprite
            updateOffsets()
        }
    }
    
    var offsetFromSpriteType : SMTextNodeOffsetFromSpriteType {
        get {
            return _offsetFromSpriteType
        }
        set(value) {
            _offsetFromSpriteType = value
            updateOffsets()
        }
    }
    
    
    var paragraphWidth:CGFloat {
        get {
            return _paragraphWidth
        }
        set(updatedWidth) {
            _paragraphWidth = updatedWidth
            self.refreshSKTexture()
        }
    }
    
    var text : String {
        get {
            return _text
        }
        set(updatedString) {
            _text = updatedString
            self.refreshSKTexture()
        }
    }
    
    var verticalAlignmentMode : SKLabelVerticalAlignmentMode {
        get {
            return _verticalAlignmentMode
        }
        set(updatedMode) {
            _verticalAlignmentMode = updatedMode
            self.refreshSKTexture()
        }
    }
    
    var horizontalAlignmentMode : SKLabelHorizontalAlignmentMode {
        get {
            return _horizontalAlignmentMode
        }
        set(updatedMode) {
            _horizontalAlignmentMode = updatedMode
            self.refreshSKTexture()
        }
    }
    
    var fontColor:UIColor {
        get {
            return _fontColor
        }
        set(updatedColor) {
            _fontColor = updatedColor
            self.refreshSKTexture()
        }
    }
    
    var fontName:String {
        get {
            return _fontName
        }
        set(updatedString) {
            _fontName = updatedString
            self.refreshSKTexture()
        }
    }
    
    var fontSize:CGFloat {
        get {
            return _fontSize
        }
        set(updatedSize) {
            _fontSize = updatedSize
            
            // make sure that this isn't below the minimum font size allowed
            if _fontSize <= SMTextNodeMinimumFontSizeAllowed {
                _fontSize = SMTextNodeMinimumFontSizeAllowed
            }
            self.refreshSKTexture()
        }
    }
    
    // MARK: - Offets and positions
    
    func updateOffsets() {
        // check if there's no sprite to offset from
        if _offsetSprite == nil {
            // use a regular offset position, if one is provided
            if _offsetFromOrigin.x != 0.0 || _offsetFromOrigin.y != 0.0 {
                let updatedPosition = SMPositionAddTwoPositions(first: self.position, second: _offsetFromOrigin)
                self.position = updatedPosition
            }
            
            return
        }
        
        //let spriteSize = _offsetSprite!.frame.size
        let halfWidthOfText = self.frame.size.width * 0.5
        let halfHeightOfText = self.frame.size.height * 0.5
        let originForOffset = _offsetSprite!.position
        var basePosition = _offsetSprite!.position
        let halfWidthOfSprite = _offsetSprite!.frame.size.width * 0.5
        let halfHeightOfSprite = _offsetSprite!.frame.size.height * 0.5
        
        switch(_offsetFromSpriteType) {
        case .CenteredOnSprite:
            basePosition = offsetSprite!.position
            
        case .AboveSprite:
            basePosition.y = originForOffset.y + halfHeightOfSprite + halfHeightOfText
            
        case .BelowSprite:
            basePosition.y = originForOffset.y - halfHeightOfSprite - halfHeightOfText
            
        case .LeftOfSprite:
            basePosition.x = originForOffset.x - halfWidthOfSprite - halfWidthOfText
            
        case .RightOfSprite:
            basePosition.x = originForOffset.x + halfWidthOfSprite + halfWidthOfText
        }
        
        self.position = SMPositionAddTwoPositions(first: basePosition, second: _offsetFromOrigin)
    }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        refreshSKTexture()
    }
    
    init(fontNamed:String) {
        // The next two lines of code exist because Swift 4 keeps throwing up error messages if I don't have them.
        // There's probably a really elegant way of getting around this, but this will do for now.
        let dummyTexture = SKTexture()
        super.init(texture: dummyTexture, color: UIColor.white, size: dummyTexture.size())
        
        _fontName = fontNamed
        refreshSKTexture()
    }
    
    init(text:String) {
        let dummyTexture = SKTexture()
        super.init(texture: dummyTexture, color: UIColor.white, size: dummyTexture.size())
        
        _text = text
        refreshSKTexture()
    }
    
    func refreshSKTexture() {
        if let newTextImage = self.imageFromText(inputText: _text) {
            let newTexture:SKTexture = SKTexture(image: newTextImage)
            self.texture = newTexture
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
    }
    
    func imageFromText(inputText:String) -> UIImage? {
        // determine what horizontal alignment mode to use
        var horizontalAlignmentToUse = NSTextAlignment.center // assume center by default
        
        // check if it's left or right instead
        if _horizontalAlignmentMode == SKLabelHorizontalAlignmentMode.left {
            horizontalAlignmentToUse = NSTextAlignment.left
        } else if _horizontalAlignmentMode == SKLabelHorizontalAlignmentMode.right {
            horizontalAlignmentToUse = NSTextAlignment.right
        }
        
        // set paragraphy style information
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping // for multi-line
        paragraphStyle.alignment = horizontalAlignmentToUse
        paragraphStyle.lineSpacing = 1
        
        var font = UIFont(name: _fontName, size: _fontSize)
        
        // If the font couldn't be successfully created, then just switch to a default font instead
        if font == nil {
            font = UIFont(name: SMTextNodeDefaultFontName, size: _fontSize)
            print("[SMTextNode] WARNING: The font you specified was unavailable, switching to \(SMTextNodeDefaultFontName) as default.")
        }
        
        let textAttributes = [
            NSAttributedStringKey.foregroundColor : _fontColor,
            NSAttributedStringKey.paragraphStyle : paragraphStyle,
            NSAttributedStringKey.font : font!
            ] as [NSAttributedStringKey : Any]
        
        // if an invalid paragraph width was passed in, use default screen width as the paragraph width instead
        if _paragraphWidth <= 0 {
            if self.scene != nil {
                _paragraphWidth = self.scene!.size.width
            }
        }
        
        // try to get paragraph height based on the scene's height (a default value gets passed in if scene data can't be retrieved)
        var paragraphHeight = SMTextNodeDefaultParagraphHeight
        if( self.scene != nil ) {
            paragraphHeight = self.scene!.size.height
        }
        
        let stringObject = NSString(string: inputText) // Convert text to NSString format
        let textRectSize = CGSize(width: paragraphWidth, height: paragraphHeight)
        
        var textRect = stringObject.boundingRect(with: textRectSize,
                                                 options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.truncatesLastVisibleLine],
                                                 attributes: textAttributes,
                                                 context: nil)
        
        // round up to "valid" values
        textRect.size.height = ceil(textRect.size.height)
        textRect.size.width = ceil(textRect.size.width)
        
        // if any of these dimensions are still zero, then there's no valid image data that can be returned
        if textRect.size.width == 0.0 || textRect.size.height == 0.0 {
            return nil
        }
        
        self.size = textRect.size
        let stringText = NSString(string: self.text)
        
        // create image context and get the data from that
        UIGraphicsBeginImageContextWithOptions(textRect.size, false, 0.0)
        stringText.draw(in: textRect, withAttributes: textAttributes)
        let image:UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image == nil {
            print("[SMTextNode] ERROR: UIImage object invalid, could not retrieve data from image context.")
        }
        
        return image
    }
}

