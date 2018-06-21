//
//  SMObject.swift
//  SporkLibrary
//
//  Created by James on 6/19/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import Foundation

/*
 SMObject
 
 This class offers some identification for itself, and also can store "child" objects -- child objects can be added,
 searched for (by name, tag, or type), and removed. This class doesn't do much else, but is meant to be subclassed,
 and can also form the basis for an entity-component relationship with subclasses.
 */
class SMObject : NSObject {
    // MARK: - Identification member variables
    
    /*
     A text name that can be used to find this object. The class uses a String reference rather than an actual string, since the reference
     uses up less memory when it's not used (meaning it's set to 'nil'). An actual String object would take up more space in memory, even
     if the string's value is just set to ""
     */
    var name:String? = nil
    
    /*
     A numerical tag, which is a faster way to identify an object (since checking number values is faster than checking if strings match).
     */
    var tag = Int(0)
    
    /*
     An array of child objects. This is stored as an NSMutableArray reference. The reference uses less memory when not actually being
     used, and using an NSMutableArray seems faster than using regular Swift arrays.
     */
    var children:NSMutableArray? = nil
    
    /*
     Reference to a parent object, if any.
     */
    var parent:SMObject? = nil

    /*
     Determines whether or not this class instance will update its children when SMObject's "update" function is called. Set to 'true' by default.
    */
    var willUpdateChildren = true
    
    // MARK: - Initialization
    
    init(withName:String) {
        name = withName
        super.init()
    }
    
    init(withTag:Int) {
        tag = withTag
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    // MARK: - Identification functions
    
    /*
     Find out if this object has a certain name. This is a simple function, but calling it is easier than determining if the
     'name' property holds valid data and then comparing the strings each time you want to find if an object has a certain name.
     */
    func isNamed(string:String) -> Bool {
        if name != nil {
            if name!.caseInsensitiveCompare(string) == .orderedSame {
                return true
            }
        }
        
        return false
    }
    
    /*
     Find out of this object has a certain tag. This is a faster way of identifying an object, compared to check its name.
     */
    func isTagged(number:Int) -> Bool {
        if tag == number {
            return true
        }
        
        return false
    }
    
    // MARK: - Parent interaction functions
    
    /*
     Called right before being added to a parent object. Should probably be overridden by subclasses that need to add extra functionality.
     */
    func willBeAddedToParent(object:SMObject) {
        parent = object
    }
    
    /*
     Called right before being removed from a parent object. Should also be overridden by subclasses that intend to add more functionality.
     */
    func willBeRemovedFromParent() {
        parent = nil
    }
    
    // MARK: - Adding child objects
    
    /*
     Adds child object to the 'children' array
     */
    func addObject(object:SMObject) {
        if children == nil {
            children = NSMutableArray()
        }
        
        object.willBeAddedToParent(object: self)
        children!.add(object)
    }
    
    /*
     Adds child object and changes its name to the string passed in
     */
    func addObject(object:SMObject, withName:String) {
        object.name = withName
        self.addObject(object: object)
    }
    
    /*
     Adds child object and changes its tag value to the integer passed in
     */
    func addObject(object:SMObject, withTag:Int) {
        object.tag = withTag
        self.addObject(object: object)
    }
    
    /*
     Adds all child nodes from an array (but only if they are SMObjects or subclasses of SMObject)
     */
    func addObjectsFromArray(array:NSArray) {
        for index in 0..<array.count {
            if let object = array.object(at: index) as? NSObject {
                if object.isKind(of: SMObject.self) {
                    self.addObject(object: object as! SMObject)
                }
            }
        }
    }
    
    // MARK: - Finding child objects
    
    /*
     Find a child object by its name
     */
    func objectNamed(string:String) -> SMObject? {
        if children == nil {
            return nil
        }
        
        for index in 0..<children!.count {
            let currentObject = children!.object(at: index) as! SMObject
            if currentObject.isNamed(string: string) == true {
                return currentObject
            }
        }
        
        return nil
    }
    
    /*
     Find child object by tag
     */
    func objectTagged(number:Int) -> SMObject? {
        if children == nil {
            return nil
        }
        
        for index in 0..<children!.count {
            let currentObject = children!.object(at: index) as! SMObject
            if currentObject.isTagged(number: number) == true {
                return currentObject
            }
        }
        
        return nil
    }
    
    /*
     Find object by specific class type
     */
    func objectOfType<ObjectType>(ofType objectClass: ObjectType.Type) -> SMObject? where ObjectType : SMObject {
        if children == nil {
            return nil
        }
        
        // For loop is done in reverse so that the last-added object is returned
        for index in (0..<children!.count).reversed() {
            let currentObject = children!.object(at: index) as! SMObject
            if currentObject.isKind(of: objectClass) {
                return currentObject
            }
        }
        
        return nil
    }
    
    // MARK: - Removing child objects
    
    /*
     Remove object by name
     */
    func removeObjectsWithName(string:String) {
        if children != nil {
            // this loop is done "in reverse" to avoid issues that arise from looping through an array that's having objects removed from it
            for index in (0..<children!.count).reversed() {
                let object = children!.object(at: index) as! SMObject
                if object.isNamed(string: string) {
                    children!.removeObject(at: index)
                }
            }
        }
    }
    
    /*
     Remove object by tag
     */
    func removeObjectsWithTag(number:Int) {
        if children != nil {
            // this loop is done "in reverse" to avoid issues that arise from looping through an array that's having objects removed from it
            for index in (0..<children!.count).reversed() {
                let object = children!.object(at: index) as! SMObject
                if object.isTagged(number: number) {
                    children!.removeObject(at: index)
                }
            }
        }
    }
    
    /*
     Remove object(s) by class type
     */
    func removeObjectOfType<ObjectType>(ofType objectClass: ObjectType.Type) where ObjectType : SMObject {
        if children != nil {
            // this loop is done "in reverse" to avoid issues that arise from looping through an array that's having objects removed from it
            for index in (0..<children!.count).reversed() {
                let object = children!.object(at: index) as! SMObject
                if object.isKind(of: objectClass) {
                    children!.removeObject(at: index)
                }
            }
        }
    }
    
    // MARK: - Updates
    
    /*
     Called once each frame. This is meant to be overriden by SMObject subclasses. The function may also update child SMObject instances in 'children'
     if 'willUpdateChildren' is set to true (it's set to true by default)
    */
    func update(deltaTime:Double) {
        if willUpdateChildren == true && children != nil {
            for index in 0..<children!.count {
                let object = children!.object(at: index) as! SMObject
                object.update(deltaTime: deltaTime)
            }
        }
    }
}
