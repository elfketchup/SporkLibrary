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
        
        let screenWidth = self.frame.size.width
        let screenHeight = self.frame.size.height
        buttonManager.autoPositionStyle = .Below
        
        //print("Screen width: \(screenWidth) | screen height: \(screenHeight)")
        
        //let label = SMTextNode(text: "Button not pressed")
        label.position = CGPoint(x: 150, y: 100)
        label.fontSize = 15
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
        
        let secondButton = SMButtonComponent(withLabelNode: SMTextNode(text: "Yo bro"),
                                             andSpriteNode: SKSpriteNode(imageNamed: "choiceboxhalf"))
        secondButton.position = CGPoint(x: 100, y: 100)
        secondButton.addToNode(node: self)
        secondButton.buttonTag = "Yo bro"
        secondButton.buttonPressedColor = UIColor.red
        let secondEntity = SMObject()
        secondEntity.addObject(object: secondButton)
        
        buttonManager.addButton(entity: buttonEntity)
        buttonManager.addButton(entity: secondEntity)

        buttonManager.autoPositionOrigin = CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.5)
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
        
        /*
        if let currentQueue = buttonManager.currentQueue() {
            //print("queue found")
            self.handleButtonQueue(array: currentQueue)
            buttonManager.removeCurrentQueue()
        }*/
        
        if let buttonQueue = buttonManager.popCurrentQueue() {
            self.handleButtonQueue(array: buttonQueue)
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
            
            buttonManager.autoPositionAnimationSpeed = 0.5
            buttonManager.autoPositionStyle = .Horizontal
        }
    }
}
