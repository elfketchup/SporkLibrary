//
//  TestScene.swift
//  SporkLibrary
//
//  Created by James on 7/3/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import SpriteKit

class TestScene : SKScene {
    
    var witchEntity = SMObject()
    var secondWitch = SMObject()
    var label = SMTextNode(fontNamed: "Helvetica")
    var distanceLabel = SMTextNode(fontNamed: "Helvetica")
    let labelWithOffset = SMTextNode(text: "This is a witch")
    
    required init?(coder aDecoder: NSCoder) {
        // does nothing
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.prepareEntityCollisionTest()
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.doEntityCollisionTest(deltaTime: currentTime)
        
        labelWithOffset.updateOffsets()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let pos = t.location(in: self)
            //print("Touched at: \(pos.x), \(pos.y)")
            self.touchEndedEntityCollisionTest(touchPos: pos)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let pos = t.location(in: self)
            self.touchMovedEntityCollisionTest(touchPos: pos)
        }
    }
    
    // MARK: - Entity collision test
    
    func prepareEntityCollisionTest() {
        label.position = CGPoint(x: 180, y: 350)
        label.fontColor = UIColor.white
        label.fontSize = 20
        self.addChild(label)
        
        distanceLabel.position = CGPoint(x: 200, y:400)
        distanceLabel.fontColor = UIColor.yellow
        distanceLabel.fontSize = 15
        self.addChild(distanceLabel)
        
        let witchSprite = SMSpriteComponent(withSpriteNode: SKSpriteNode(imageNamed: "witch1"))
        witchSprite.setPosition(point: CGPoint(x: 100, y: 100))
        witchSprite.addToNode(node: self)
        witchEntity.addObject(object: witchSprite)
        
        let witchMover = SMMovementComponent(withSpriteComponent: witchSprite)
        witchMover.velocity = CGPoint(x: 1, y: 2)
        witchEntity.addObject(object: witchMover)
        
        let witchCollision = SMCollisionComponent(withSpriteComponent: witchSprite)
        //let witchCollision = SMCollisionComponent(withName:"collider")
        witchCollision.canGoOffscreen = false
        witchCollision.bounceOffScreenEdges = true
        witchCollision.collisionType = .Box
        witchEntity.addObject(object: witchCollision)
        
        /** SECOND WITCH ENTITY **/
        
        let witchSpriteTwo = SMSpriteComponent(withSpriteNode: SKSpriteNode(imageNamed: "witch1"))
        witchSpriteTwo.setPosition(point: CGPoint(x: 200, y: 300))
        witchSpriteTwo.addToNode(node: self)
        secondWitch.addObject(object: witchSpriteTwo)
        
        let secondCollider = SMCollisionComponent(withSpriteComponent: witchSpriteTwo)
        secondWitch.addObject(object: secondCollider)
        
        labelWithOffset.fontSize = 16
        labelWithOffset.offsetSprite = SMSpriteNodeFromEntity(entity: secondWitch)
        labelWithOffset.offsetFromSpriteType = .AboveSprite
        self.addChild(labelWithOffset)
    }
    
    func touchMovedEntityCollisionTest(touchPos:CGPoint) {
        if let secondWitchSprite = secondWitch.objectOfType(ofType: SMSpriteComponent.self) as? SMSpriteComponent {
            secondWitchSprite.setPosition(point: touchPos)
        }
    }
    
    func touchEndedEntityCollisionTest(touchPos:CGPoint) {
        if let collider = witchEntity.objectOfType(ofType: SMCollisionComponent.self) as? SMCollisionComponent {
            if collider.isPointCollidingWithCircle(point: touchPos) == true {
            //if collider.isPointCollidingWithCollisionBox(point: touchPos) {
                label.text = "Entity was touched!"
            } else {
                label.text = "Entity not touched..."
            }
        } else {
            print("No collision detection on entity.")
        }
    }
    
    func doEntityCollisionTest(deltaTime:TimeInterval) {
        witchEntity.update(deltaTime: deltaTime)
        secondWitch.update(deltaTime: deltaTime)
        
        // TRACK DISTANCE
        /*if let firstWitchCollider = witchEntity.objectOfType(ofType: SMCollisionComponent.self) as? SMCollisionComponent {
            let distance = firstWitchCollider.distanceFromEntity(entity: secondWitch)
            distanceLabel.text = "Distance between sprites: \(distance)"
        }*/
    }
}
