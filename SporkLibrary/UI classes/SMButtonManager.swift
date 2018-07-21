//
//  SMButtonManager.swift
//  SporkLibrary
//
//  Created by James on 7/18/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

class SMButtonManagerQueueItem {
    var tag = ""
    var level = 0
}

class SMButtonManager : SMObject {
    // MARK: - Instance variables
    
    // Determines which "level" of input is accepting touch input (level 0 accepts all touches all the time)
    var currentLevel = Int(1)
    
    // Array of buttons which have been pressed (each item in the array is an instance of SMButtonManagerQueueItem)
    var queue = NSMutableArray()
    
    
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
    
    func allQueueItems() -> NSArray? {
        if queue.count < 1 {
            return nil
        }
        
        return NSArray(array: queue)
    }
    
    func currentQueue() -> NSArray? {
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
    
    func mostRecentQueueItem() -> SMButtonManagerQueueItem? {
        if queue.count > 0 {
            if let lastItem = queue.lastObject as? SMButtonManagerQueueItem {
                return lastItem
            }
        }
        
        return nil
    }
    
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
 
    // MARK: - Removing items from queue
    
    func removeCurrentQueue() {
        if currentLevel > 0 {
            self.removeItemsOfCurrentLevel()
        }
        
        self.removeItemsOfLevel(level: 0)
    }
    
    func removeAllItemsInQueue() {
        queue.removeAllObjects()
    }
    
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
    
    func removeItemsOfCurrentLevel() {
        self.removeItemsOfLevel(level: currentLevel)
    }
    
    func removeMostRecentQueueItem()  {
        if queue.count < 1 {
            return
        }
        
        queue.removeLastObject()
    }
    
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
    
    func removeMostRecentQueueItemOfCurrentLevel() {
        self.removeMostRecentQueueItemOfLevel(level: currentLevel)
    }
    
    
    // MARK: - Touch input
    
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
