//
//  GameScene.swift
//  BirdFly
//
//  Created by Melisse Cabral on 12/9/17.
//  Copyright (c) 2017 Melisse Cabral. All rights reserved.
//

import SpriteKit
import AVFoundation

struct PhysicsCatagory {
    static let char : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var Ground = SKSpriteNode()
    var char = SKSpriteNode()
    
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    var score = Int()
    let scoreLbl = SKLabelNode()
    
    var gameStarted = Bool()
    var died = Bool()
    var restartBTN = SKSpriteNode()
    
    var player = AVAudioPlayer()
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    func playSound(){
        
        let url = NSBundle.mainBundle().URLForResource("blackbird", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
            
            player.prepareToPlay()
            player.play()
            
        } catch let error as NSError {
            print(error.description)
        }
        player.numberOfLoops = -1
        
    }
    func createScene(){
        
        self.physicsWorld.contactDelegate = self
        
        let bg = SKSpriteNode(imageNamed: "bgd")
        bg.name = "background"
        bg.anchorPoint = CGPointZero
        bg.position = CGPoint(x: frame.size.width / 8, y: frame.size.height/16)
        bg.zPosition = -10
        self.addChild(bg)
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.fontName = "04b_19"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 60
        self.addChild(scoreLbl)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCatagory.char
        Ground.physicsBody?.contactTestBitMask  = PhysicsCatagory.char
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        
        
        char = SKSpriteNode(imageNamed: "char")
        char.size = CGSize(width: 55, height: 65)
        char.position = CGPoint(x: self.frame.width / 2 - char.frame.width, y: self.frame.height / 2)
        
        char.physicsBody = SKPhysicsBody(circleOfRadius: char.frame.height / 2)
        char.physicsBody?.categoryBitMask = PhysicsCatagory.char
        char.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall
        char.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
        char.physicsBody?.affectedByGravity = false
        char.physicsBody?.dynamic = true
        
        char.zPosition = 2
        
        
        self.addChild(char)

    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        createScene()
        
    }
    
    func createBTN(){
        
        restartBTN = SKSpriteNode(imageNamed: "RestartBtn")
        restartBTN.size = CGSizeMake(200, 100)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        restartBTN.runAction(SKAction.scaleTo(1.0, duration: 0.3))
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.char{
            
            score++
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        }
        else if firstBody.categoryBitMask == PhysicsCatagory.char && secondBody.categoryBitMask == PhysicsCatagory.Score {
            
            score++
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
            
        }
            
        else if firstBody.categoryBitMask == PhysicsCatagory.char && secondBody.categoryBitMask == PhysicsCatagory.Wall || firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.char{
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createBTN()
            }
        }
        else if firstBody.categoryBitMask == PhysicsCatagory.char && secondBody.categoryBitMask == PhysicsCatagory.Ground || firstBody.categoryBitMask == PhysicsCatagory.Ground && secondBody.categoryBitMask == PhysicsCatagory.char{
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createBTN()
            }
        }
        
        
        
        
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameStarted == false{
            
            gameStarted =  true
            playSound()
            char.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock({
                () in
                
                self.createWalls()
                
            })
        
            let delay = SKAction.waitForDuration(2.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(spawnDelayForever)
            
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.009 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            char.physicsBody?.velocity = CGVectorMake(0, 0)
            char.physicsBody?.applyImpulse(CGVectorMake(0, 85))
        }
        else{
            
            if died == true{
                
                
            }
            else{
                char.physicsBody?.velocity = CGVectorMake(0, 0)
                char.physicsBody?.applyImpulse(CGVectorMake(0, 85))
            }
            
        }
        
        
        
        
        for touch in touches{
            let location = touch.locationInNode(self)
            
            if died == true{
                if restartBTN.containsPoint(location){
                    restartScene()
                    
                }
                
                
            }
            
        }
        
    }
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.char
        scoreNode.color = SKColor.blueColor()
        
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 375)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 375)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCatagory.char
        topWall.physicsBody?.contactTestBitMask = PhysicsCatagory.char
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCatagory.char
        btmWall.physicsBody?.contactTestBitMask = PhysicsCatagory.char
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
     
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y +  randomPosition
        
        wallPair.addChild(scoreNode)
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted == true{
            if died == false{
                enumerateChildNodesWithName("background", usingBlock: ({
                    (node, error) in
                    
                    var bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                        
                    }
                    
                }))
                
            } else {
                player.stop()
            }
            
            
        }
        
        
        
        
    }
}