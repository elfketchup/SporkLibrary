//
//  ButtonTestScene.swift
//  SporkLibrary
//
//  Created by James on 7/16/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

class ButtonTestScene : SKScene {
    
    var buttonEntity = SMObject()
    var label = SMTextNode(text: "Button not pressed")
    var buttonManager = SMButtonManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        loadButtonTest()
    }
    
    func loadButtonTest() {
        
        //let label = SMTextNode(text: "Button not pressed")
        label.position = CGPoint(x: 150, y: 300)
        label.fontSize = 21
        self.addChild(label)
        
        let textOffset = CGPoint(x: 0, y: 0)
        
        let buttonSprite = SKSpriteNode(imageNamed: "choiceboxhalf")
        //let buttonSpriteRed = SKSpriteNode(imageNamed: "choiceboxhalf_red")
        let labelNode = SMTextNode(text: "Hey there")
        labelNode.fontSize = 16
        
        //let buttonComponent = SMButtonComponent(withLabelNode: labelNode, andSpriteNode: buttonSprite, andButtonPressedNode: buttonSpriteRed)
        let buttonComponent = SMButtonComponent(withLabelNode: labelNode, andSpriteNode: buttonSprite)
        buttonComponent.position = CGPoint(x: 200, y: 200)
        buttonComponent.addToNode(node: self)
        buttonComponent.labelOffset = textOffset
        buttonComponent.buttonPressedColor = UIColor.cyan
        buttonComponent.buttonNormalColor = UIColor.white
        buttonComponent.buttonTag = "Hey"
        
        buttonEntity.addObject(object: buttonComponent)
        
        buttonManager.addButton(entity: buttonEntity)
    }
    
    // MARK: - Update
    
    func handleButtonQueue(array:NSArray) {
        for i in 0..<array.count {
            let queueItem = array.object(at: i) as! SMButtonManagerQueueItem
            label.text = "Button pressed tagged as \(queueItem.tag)"
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        buttonManager.update(deltaTime: currentTime)
        
        if let currentQueue = buttonManager.currentQueue() {
            //print("queue found")
            self.handleButtonQueue(array: currentQueue)
            buttonManager.removeCurrentQueue()
        }
        
        /*buttonEntity.update(deltaTime: currentTime)
        
        if let button = SMButtonComponentFromEntity(entity: buttonEntity) {
            if button.touchEndedHere == true {
                label.text = "Button is being pressed"
            } else {
                label.text = "Button not pressed"
            }
        }*/
    }
    
    // MARK: - Input
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let pos = t.location(in: self)
            /*if let button = SMButtonComponentFromEntity(entity: buttonEntity) {
                button.touchBeganAt(point: pos)
            }*/
            buttonManager.touchBeganAt(point: pos)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let pos = t.location(in: self)
            /*if let button = SMButtonComponentFromEntity(entity: buttonEntity) {
                button.touchMovedTo(point: pos)
            }*/
            buttonManager.touchMovedTo(point: pos)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let pos = t.location(in: self)
            /*if let button = SMButtonComponentFromEntity(entity: buttonEntity) {
                button.touchEndedAt(point: pos)
            }*/
            buttonManager.touchEndedAt(point: pos)
        }
    }
}
