//
//  SMButtonManager.swift
//  SporkLibrary
//
//  Created by James on 7/18/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

// MARK: - Dictionary keys
let SMButtonManagerArrayOfButtonsKey        = "buttons"     // array, each index is a dictionary that can load an SMButtonComponent
let SMButtonManagerSKNodeToAddButtonsToKey  = "node"        // SKNode, add parent
let SMButtonManagerZForButtonsKey           = "z"           // CGFloat, determines Z position for buttons loaded by manager and added to parent node
let SMButtonManagerOriginXKey               = "origin x"    // CGFloat, x-coordinate for origin when auto-positioning sprites
let SMButtonManagerOriginYKey               = "origin y"    // CGFloat, y-coordinate for origin when auto-positioning sprites
let SMButtonManagerAutoPositionMarginKey    = "margin"      // CGFloat, space between buttons when auto-positioning
let SMButtonManagerAnimationSpeedKey        = "animation speed" // Double, speed when animating auto-positioning
let SMButtonManagerPositioningStyleKey      = "style"       // String, determines what kind of auto-positioning scheme to use (default is none)

// String values for 'SMButtonManagerPositioningStyleKey'
let SMButtonManagerPositioningStyleNone         = "none"
let SMButtonManagerPositioningStyleLeft         = "left"
let SMButtonManagerPositioningStyleRight        = "right"
let SMButtonManagerPositioningStyleAbove        = "above"
let SMButtonManagerPositioningStyleBelow        = "below"
let SMButtonManagerPositioningStyleHorizontal   = "horizontal"
let SMButtonManagerPositioningStyleVertical     = "vertical"

enum SMButtonManagerPositioningStyle : Int8 {
    case None       = 0 // no auto positioning
    case Left       = 1 // buttons are added going left
    case Right      = 2 // buttons are added going right
    case Above      = 3 // buttons are added going up
    case Below      = 4 // buttons are added going down
    case Horizontal = 5 // buttons are added left and right (centered around "origin")
    case Vertical   = 6 // buttons are added up and down (centering around "origin")
}

/*
 SMButtonManagerQueueItem
 
 Doesn't do anything, just holds very basic information regarding which button was pressed and what level it is
 */
class SMButtonManagerQueueItem {
    var tag = ""
    var level = 0
}

/*
 SMButtonManager
 
 Manages multiple buttons at once; each button is represented by an entity (SMObject) which holds an SMButtonComponent component.
 The manager can pass along touch input to each button. Every time a button is pressed, it's recorded in the queue, which other
 classes can read from in order to handle touch input.
 
 More complex interfaces can have "levels," in which only buttons of a certain level can be interacted with. This can be done for menus,
 windows, and other types of complex interfaces. Buttons of level zero will always be interacted with no matter what.
 */
class SMButtonManager : SMObject {
    // MARK: - Instance variables
    
    // Determines which "level" of input is accepting touch input (level 0 accepts all touches all the time)
    var currentLevel = Int(1)
    
    // Array of buttons which have been pressed (each item in the array is an instance of SMButtonManagerQueueItem)
    var queue = NSMutableArray()
    
    // Pointer to SKNode where the buttons could be added to
    var parentNode : SKNode? = nil
    
    // Z position for nodes created by dictionary
    var zPosition = CGFloat(1)
    
    // Origin point for buttons that are added and "auto-positioned"
    var _origin = CGPoint(x: 0, y: 0)
    var autoPositionOrigin : CGPoint {
        get {
            return _origin
        }
        set(point) {
            _origin = point
            autoUpdatePositions()
        }
    }
    
    // Gap between buttons when auto-positioned
    var _autoPositionMargin = CGFloat(10.0)
    var autoPositionMargin : CGFloat {
        get {
            return _autoPositionMargin
        }
        set(margin) {
            _autoPositionMargin = margin
            autoUpdatePositions()
        }
    }
    
    // Positioning styles for when buttons are added
    var _autoPositionStyle = SMButtonManagerPositioningStyle.None
    var autoPositionStyle : SMButtonManagerPositioningStyle {
        get {
            return _autoPositionStyle
        }
        set(style) {
            _autoPositionStyle = style
            autoUpdatePositions()
        }
    }
    
    // Animation speed for changing button positions (zero means no animation)
    var autoPositionAnimationSpeed = Double(0)
    
    
    // MARK: - Initialization
    
    override init(withDictionary: NSDictionary) {
        super.init()
        self.loadFromDictionary(dictionary: withDictionary)
    }
    
    override init() {
        super.init()
    }
    
    // MARK: - Loading from dictionary
    
    override func loadFromDictionary(dictionary: NSDictionary) {
        super.loadFromDictionary(dictionary: dictionary)
        
        // Add parent node
        if let parentNodeFromDictionary = dictionary.object(forKey: SMButtonManagerSKNodeToAddButtonsToKey) as? SKNode {
            parentNode = parentNodeFromDictionary
        }
        
        if let zFromDictionary = dictionary.object(forKey: SMButtonManagerZForButtonsKey) as? NSNumber {
            zPosition = CGFloat(zFromDictionary.doubleValue)
        }
        
        if let originX = dictionary.object(forKey: SMButtonManagerOriginXKey) as? NSNumber {
            _origin.x = CGFloat(originX.doubleValue)
        }
        if let originY = dictionary.object(forKey: SMButtonManagerOriginYKey) as? NSNumber {
            _origin.y = CGFloat(originY.doubleValue)
        }
        
        if let marginValue = dictionary.object(forKey: SMButtonManagerAutoPositionMarginKey) as? NSNumber {
            _autoPositionMargin = CGFloat(marginValue.doubleValue)
        }
        
        if let animationSpeedValue = dictionary.object(forKey: SMButtonManagerAnimationSpeedKey) as? NSNumber {
            autoPositionAnimationSpeed = animationSpeedValue.doubleValue
        }
        
        if let positioningStyleValue = dictionary.object(forKey: SMButtonManagerPositioningStyleKey) as? String {
            _autoPositionStyle = self.autopositionStyleFromString(string: positioningStyleValue)
        }

        // Add any buttons that were passed in from an array; each item in the array is an NSDictionary that loads an SMButtonComponent object
        self.loadArrayOfButtonsFromDictionary(dictionary: dictionary)
    }
    
    /*
     let SMButtonManagerPositioningStyleNone         = "none"
     let SMButtonManagerPositioningStyleLeft         = "left"
     let SMButtonManagerPositioningStyleRight        = "right"
     let SMButtonManagerPositioningStyleAbove        = "above"
     let SMButtonManagerPositioningStyleBelow        = "below"
     let SMButtonManagerPositioningStyleHorizontal   = "horizontal"
     let SMButtonManagerPositioningStyleVertical     = "vertical"
 */
    
    func autopositionStyleFromString(string:String) -> SMButtonManagerPositioningStyle {
        if SMStringsAreSame(first: string, second: SMButtonManagerPositioningStyleLeft) {
            return .Left
        } else if SMStringsAreSame(first: string, second: SMButtonManagerPositioningStyleRight) {
            return .Right
        } else if SMStringsAreSame(first: string, second: SMButtonManagerPositioningStyleAbove) {
            return .Above
        } else if SMStringsAreSame(first: string, second: SMButtonManagerPositioningStyleBelow) {
            return .Below
        } else if SMStringsAreSame(first: string, second: SMButtonManagerPositioningStyleVertical) {
            return .Vertical
        } else if SMStringsAreSame(first: string, second: SMButtonManagerPositioningStyleHorizontal) {
            return .Horizontal
        }
        
        return .None
    }
    
    func loadArrayOfButtonsFromDictionary(dictionary:NSDictionary) {
        if let buttonInfoArray = dictionary.object(forKey: SMButtonManagerArrayOfButtonsKey) as? NSArray {
            for i in 0..<buttonInfoArray.count {
                // load button component from dictionary
                let buttonDictionary = buttonInfoArray.object(at: i) as! NSDictionary       // load NSDictionary object from array
                let buttonComponent = SMButtonComponent(withDictionary: buttonDictionary)   // create button component using NSDictionary
                
                // add button component to entity
                let entity = SMObject()
                entity.addObject(object: buttonComponent)
                
                // add entity to manager
                self.addButton(entity: entity)
                
                // Check if a custom Z position should be used for buttons
                if buttonComponent.zPosition <= 1 {
                    buttonComponent.zPosition = self.zPosition
                }
                
                // Check if a parent node exists for the buttons to be added to
                if parentNode != nil {
                    buttonComponent.addToNode(node: parentNode!)
                }
            }
        }
    }
    
    // MARK: - Auto-positioning buttons
    
    func autoUpdatePositionOfButtonComponent(component:SMButtonComponent, indexNumber:Int) {
        if children == nil || children!.count < 1 || _autoPositionStyle == .None {
            return
        }
        
        let buttonFrame = component.frame()
        if buttonFrame == nil {
            return
        }
        
        let totalNumberOfButtons    = children!.count
        let totalAsDouble           = CGFloat(totalNumberOfButtons)
        var buttonPosition          = _origin
        let buttonWidth             = buttonFrame!.size.width
        let buttonHeight            = buttonFrame!.size.height
        let indexAsDouble           = CGFloat(indexNumber)
        let totalHorizontalWidth    = totalAsDouble * (buttonWidth + _autoPositionMargin)
        let totalVerticalHeight     = totalAsDouble * (buttonHeight + _autoPositionMargin)
        
        // Work out what the position should be
        switch(_autoPositionStyle) {
        case .Above:
            buttonPosition.y = _origin.y + ((_autoPositionMargin + buttonHeight) * indexAsDouble)
            
        case .Below:
            buttonPosition.y = _origin.y - (indexAsDouble * (buttonHeight + _autoPositionMargin))
            
        case .Left:
            buttonPosition.x = _origin.x - (indexAsDouble * (buttonWidth + _autoPositionMargin))
            
        case .Right:
            buttonPosition.x = _origin.x + (indexAsDouble * (buttonWidth + _autoPositionMargin))
            
        case .Horizontal: // left to right
            let originForHorizontal = _origin.x - (totalHorizontalWidth * 0.5)
            let initalOffset = (buttonWidth * 0.5) + (_autoPositionMargin * 0.5)
            buttonPosition.x = originForHorizontal + initalOffset + (indexAsDouble * (buttonWidth + _autoPositionMargin))
            
        case .Vertical: // up to down
            let originForVertical = _origin.y + (totalVerticalHeight * 0.5)
            let initialOffset = (buttonHeight * 0.5) + (_autoPositionMargin * 0.5)
            buttonPosition.y = originForVertical - initialOffset - (indexAsDouble * (buttonHeight + _autoPositionMargin))
            
        default:
            // nothing happens?
            buttonPosition = _origin
        }
        
        // Apply calculations
        if autoPositionAnimationSpeed <= 0.0 {
            component.position = buttonPosition
        } else {
            print("[SMButtonManager] WARNING: Animation of button auto-positioning not implemented yet.")
            component.position = buttonPosition
        }
    }
    
    func autoUpdatePositions() {
        if children == nil || children!.count < 1 {
            return // no valid data to work with
        }
        
        // check if this isn't meant to be auto-positioned in the first place
        if autoPositionStyle == .None {
            return
        }
        
        for index in 0..<children!.count {
            let entity = children!.object(at: index) as! SMObject
            if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
                self.autoUpdatePositionOfButtonComponent(component: buttonComponent, indexNumber: index)
            } // end if buttonComponent
        } // end for loop
    } // end function
    
    // MARK: - Adding individual buttons
    
    func addButton(entity:SMObject, level:Int, buttonTag:String) {
        if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
            buttonComponent.level = level
            buttonComponent.buttonTag = buttonTag
            self.addObject(object: entity)
        }
    }
    
    func addButton(entity:SMObject, level:Int) {
        if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
            buttonComponent.level = level
            self.addObject(object: entity)
        }
    }
    
    func addButton(entity:SMObject, buttonTag:String) {
        if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
            buttonComponent.buttonTag = buttonTag
            self.addObject(object: entity)
        }
    }
    
    func addButton(entity:SMObject) {
        if entity.objectOfType(ofType: SMButtonComponent.self) != nil {
            self.addObject(object: entity)
        }
    }
    
    // MARK: - Add array of buttons
    
    func addArrayOfButtons(buttons:NSArray) {
        for i in 0..<buttons.count {
            let item = buttons.object(at: i) as! SMObject
            self.addButton(entity: item)
        }
    }
    
    func addArrayOfButtons(buttons:NSArray, level:Int) {
        for i in 0..<buttons.count {
            let item = buttons.object(at: i) as! SMObject
            self.addButton(entity: item, level: level)
        }
    }
    
    // MARK: - Identifying buttons
    
    func tagForButton(component:SMButtonComponent) -> String? {
        // check if the string length is long enough (the default value for the tag has a string length of 0)
        if SMStringLength(string: component.buttonTag) > 0 {
            return component.buttonTag
        }
        
        // Try using the label node text (if it exists)
        if component.labelNode != nil {
            if SMStringLength(string: component.labelNode!.text) > 0 {
                return component.labelNode!.text
            }
        }
        
        // Try using the entity name
        if component.parent != nil && component.parent!.name != nil {
            return component.parent!.name!
        }
        
        return nil
    }
    
    // MARK: - Level adjustments
    
    func moveLevelUp() {
        currentLevel += 1
    }
    
    func moveLevelDown() {
        if currentLevel > 1 {
            currentLevel -= 1
        }
    }
    
    // MARK: - Adding button components to queue
    
    func addButtonComponentToQueue(component:SMButtonComponent) {
        let queueItem = SMButtonManagerQueueItem()
        var queueItemTag = "\(queue.count)"
        
        // Determine if there's a valid tag name
        if let usefulTag = self.tagForButton(component: component) {
            queueItemTag = usefulTag
        }
        
        // Use the button component's level value
        queueItem.level = component.level
        queueItem.tag = queueItemTag
        
        // Add to array
        queue.add(queueItem)
    }
    
    // MARK: - Retrieving items from queue
    
    // Retrieve all queue items, regardless of level
    func allQueueItems() -> NSArray? {
        if queue.count < 1 {
            return nil
        }
        
        return NSArray(array: queue)
    }
    
    // Retrieve queue items of level 0 and whatever the current level is (presumably NOT zero)
    func currentQueue() -> NSArray? {
        // don't bother if the queue is completely empty
        if queue.count < 1 {
            return nil
        }
        
        let allValidItems = NSMutableArray()
        
        if currentLevel < 1 {
            return self.queueItemsOfLevel(level: 0)
        }
        
        for i in 0..<queue.count {
            let queueItem = queue.object(at: i) as! SMButtonManagerQueueItem
            
            if queueItem.level == 0 || queueItem.level == currentLevel {
                allValidItems.add(queueItem)
            }
        }
        
        if allValidItems.count < 1 {
            return nil
        }
        
        return NSArray(array: allValidItems) // return immutable copy
    }
    
    // returns array of all queue items of a particular level
    func queueItemsOfLevel(level:Int) -> NSArray? {
        if queue.count < 1 {
            return nil
        }
        
        let arrayOfQueueItems = NSMutableArray()
        
        for i in 0..<queue.count {
            let queueItem = queue.object(at: i) as! SMButtonManagerQueueItem
            if queueItem.level == level {
                arrayOfQueueItems.add(queueItem)
            }
        }
        
        if arrayOfQueueItems.count < 1 {
            return nil
        }
        
        return NSArray(array: arrayOfQueueItems) // return immutable copy
    }
    
    // returns the most recent item in the queue, regardless of level
    func mostRecentQueueItem() -> SMButtonManagerQueueItem? {
        if queue.count > 0 {
            if let lastItem = queue.lastObject as? SMButtonManagerQueueItem {
                return lastItem
            }
        }
        
        return nil
    }
    
    // returns the most recent item in the queue of a certain level
    func mostRecentQueueItemOfLevel(level:Int) -> SMButtonManagerQueueItem? {
        if queue.count < 1 {
            return nil
        }
        
        for i in (0..<queue.count).reversed() {
            let queueItem = queue.object(at: i) as! SMButtonManagerQueueItem
            
            if queueItem.level == level {
                return queueItem
            }
        }
        
        return nil
    }
    
    // returns array of queue items of level zero and the current level, and then removes those items from the queue
    func popCurrentQueue() -> NSArray? {
        if let temporaryArray = self.currentQueue() {
            // make a copy
            let copyOfArray = NSArray(array: temporaryArray)
            
            // Remove all previous data
            self.removeCurrentQueue()
            
            return copyOfArray
        }
        
        return nil
    }
 
    // MARK: - Removing items from queue
    
    // removes all queue items of level zero and the current level
    func removeCurrentQueue() {
        if currentLevel > 0 {
            self.removeItemsOfCurrentLevel()
        }
        
        self.removeItemsOfLevel(level: 0)
    }
    
    // removes everything in the queue
    func removeAllItemsInQueue() {
        queue.removeAllObjects()
    }
    
    // removes all items of a certain level
    func removeItemsOfLevel(level:Int) {
        if queue.count < 1 {
            return
        }
        
        for i in (0..<queue.count).reversed() {
            let queueItem = queue.object(at: i) as! SMButtonManagerQueueItem
            if queueItem.level == level {
                queue.removeObject(at: i)
            }
        }
    }
    
    // removes all items of the current level
    func removeItemsOfCurrentLevel() {
        self.removeItemsOfLevel(level: currentLevel)
    }
    
    // removes most recent queue item (regardless of level)
    func removeMostRecentQueueItem()  {
        if queue.count < 1 {
            return
        }
        
        queue.removeLastObject()
    }
    
    // removes most recent item in queue of a particular level
    func removeMostRecentQueueItemOfLevel(level:Int) {
        if queue.count < 1 {
            return
        }
        
        for i in (0..<queue.count).reversed() {
            let queueItem = queue.object(at: i) as! SMButtonManagerQueueItem
            if queueItem.level == level {
                queue.removeObject(at: i)
                return
            }
        }
    }
    
    // removes most recent item in the queue of the current level
    func removeMostRecentQueueItemOfCurrentLevel() {
        self.removeMostRecentQueueItemOfLevel(level: currentLevel)
    }
    
    // MARK: - Sprite functionality
    
    // remove button sprites from their parent node (but only of a certan level)
    func removeButtonSpritesFromParent(level:Int) {
        if children == nil || children!.count < 1 {
            return
        }
        
        for i in 0..<children!.count {
            let entity = children!.object(at: i) as! SMObject
            if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
                if buttonComponent.level == level {
                    buttonComponent.removeFromParentNode()
                }
            }
        }
    }
    
    // remove all button sprites from parent node (regardless of level)
    func rmeoveAllButtonSpritesFromParent() {
        if children == nil || children!.count < 1 {
            return
        }
        
        for i in 0..<children!.count {
            let entity = children!.object(at: i) as! SMObject
            if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
                buttonComponent.removeFromParentNode()
            }
        }
    }
    
    
    // MARK: - Touch input
    
    // handle touch input for all buttons of level 0 and the current level
    func touchBeganAt(point:CGPoint) {
        if children == nil || children!.count < 1 {
            return
        }
        
        for i in 0..<children!.count {
            let entity = children!.object(at: i) as! SMObject
            if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
                if buttonComponent.level == 0 || buttonComponent.level == currentLevel {
                    buttonComponent.touchBeganAt(point: point)
                }
            }
        }
    }
    
    // handle moving touch input for buttons of level 0 and current level (doesn't really do much)
    func touchMovedTo(point:CGPoint) {
        if children == nil || children!.count < 1 {
            return
        }
        
        for i in 0..<children!.count {
            let entity = children!.object(at: i) as! SMObject
            if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
                if buttonComponent.level == 0 || buttonComponent.level == currentLevel {
                    buttonComponent.touchMovedTo(point: point)
                }
            }
        }
    }
    
    // handle end touch input for buttons of level 0 and current level (button functionality is mostly concentrated here)
    func touchEndedAt(point:CGPoint) {
        if children == nil || children!.count < 1 {
            return
        }
        
        for i in 0..<children!.count {
            let entity = children!.object(at: i) as! SMObject
            if let buttonComponent = SMButtonComponentFromEntity(entity: entity) {
                if buttonComponent.level == 0 || buttonComponent.level == currentLevel {
                    buttonComponent.touchEndedAt(point: point)
                
                    if buttonComponent.touchEndedHere == true {
                        self.addButtonComponentToQueue(component: buttonComponent)
                    }
                }
            }
        }
    }
    
    
    
}
