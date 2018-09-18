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
    
    
    let barEntity = SMObject()
    
    // drag and drop test variables
    let dragDropArray = NSMutableArray()
    var dropZoneWitch = SMObject()
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let pos = t.location(in: self)
            
            if let witchDragComponent = secondWitch.objectOfType(ofType: SMDragSpriteComponent.self) as? SMDragSpriteComponent {
                witchDragComponent.touchBeganAt(point: pos)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let pos = t.location(in: self)
            //print("Touched at: \(pos.x), \(pos.y)")
            self.touchEndedEntityCollisionTest(touchPos: pos)
            
            if let witchDragComponent = secondWitch.objectOfType(ofType: SMDragSpriteComponent.self) as? SMDragSpriteComponent {
                witchDragComponent.touchEndedAt(point: pos)
                
                print("Witch drag start: \(witchDragComponent.touchBeganPoint.x), \(witchDragComponent.touchBeganPoint.y)")
                print("Witch drag end: \(witchDragComponent.touchEndedPoint.x), \(witchDragComponent.touchEndedPoint.x)")
                let touchMoveDistance = SMMathDistanceBetweenPoints(first: witchDragComponent.touchBeganPoint, second: witchDragComponent.touchEndedPoint)
                print("Touch move distance = \(touchMoveDistance)")
                
                let angleOfMove = witchDragComponent.angleInDegreesFromTouchBeganToEnd()
                print("Angle of move was: \(angleOfMove)")
            }
        }
        
        self.randomizeDisplayBar()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let pos = t.location(in: self)
            if let witchDragComponent = secondWitch.objectOfType(ofType: SMDragSpriteComponent.self) as? SMDragSpriteComponent {
                witchDragComponent.touchMovedTo(point: pos)
            }
            //self.touchMovedEntityCollisionTest(touchPos: pos)
        }
    }
    
    func randomizeDisplayBar() {
        if let component = barEntity.objectOfType(ofType: SMBarDisplayComponent.self) as? SMBarDisplayComponent {
            let randomFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            //print("Random float generated = \(randomFloat)")
            component.length = randomFloat
            
            component.labelNode!.text = "\(randomFloat)"
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
        
        // CRAFT BAR
        makeBarDisplay()
        
        // set up drag drop test
        let witchDragComponent = SMDragSpriteComponent(withSpriteComponent: witchSpriteTwo)
        secondWitch.addObject(object: witchDragComponent)
        self.setupDragDropTest()
    }
    
    func setupDragDropTest() {
        // add second witch to drop zone array
        dragDropArray.add(secondWitch)
        
        let spriteForDropWitch = SKSpriteNode(imageNamed: "witch1")
        spriteForDropWitch.colorBlendFactor = 1.0
        spriteForDropWitch.color = UIColor.red
        spriteForDropWitch.position = CGPoint(x: 60, y: 300)
        self.addChild(spriteForDropWitch)
        //let spriteComponentForDropWitch = SMSpriteComponent(withSpriteNode: spriteForDropWitch)
        //dropZoneWitch.addObject(object: spriteComponentForDropWitch)
        
        let dropZoneComponent = SMDragDropLocationComponent(withSpriteNode: spriteForDropWitch)
        dropZoneWitch.addObject(object: dropZoneComponent)
        dropZoneComponent.arrayOfEntitiesToCheck = dragDropArray
    }
    
    func makeBarDisplay() {
        let component = SMBarDisplayComponent(barSpriteName: "choiceboxhalf_red")
        component.backgroundBar = SKSpriteNode(imageNamed: "choiceboxhalf")
        component.labelNode = SMTextNode(text: "Tap to change value")
        component.labelNode!.fontSize = 14
        component.position = CGPoint(x: 200, y: 80)
        
        barEntity.addObject(object: component)
        component.addToNode(node: self)
        
        component.barAlignment = .Left
        component.textAlignment = .Center
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
        dropZoneWitch.update(deltaTime: deltaTime)
        
        // TRACK DISTANCE
        /*if let firstWitchCollider = witchEntity.objectOfType(ofType: SMCollisionComponent.self) as? SMCollisionComponent {
            let distance = firstWitchCollider.distanceFromEntity(entity: secondWitch)
            distanceLabel.text = "Distance between sprites: \(distance)"
        }*/
    }
}
