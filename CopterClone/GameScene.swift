//
//  GameScene.swift
//  CopterClone
//
//  Created by Bradley Vidler on 2014-10-21.
//  Copyright (c) 2014 Bradley Vidler. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let backgroundLayer = SKNode()
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var velocity = CGPointZero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let bird: SKSpriteNode = SKSpriteNode(imageNamed: "bird1Animate1")
    let copter: SKSpriteNode = SKSpriteNode(imageNamed: "copterAnimation1")
    let birdAnimation: SKAction
    let copterAnimation: SKAction
    let birdMovePointsPerSec:CGFloat = 480.0
    let birdRotateRadiansPerSec:CGFloat = 4.0 * π
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
            width: size.width,
            height: playableHeight)
        
        var birdTextures:[SKTexture] = []
        var copterTextures:[SKTexture] = []

        for i in 1...3 {
            birdTextures.append(SKTexture(imageNamed: "Bird1Animate\(i)"))
        }

        birdTextures.append(birdTextures[2])
        birdTextures.append(birdTextures[1])
        
        birdAnimation = SKAction.repeatActionForever(
            SKAction.animateWithTextures(birdTextures, timePerFrame: 0.75))
        
        for i in 1...6 {
            copterTextures.append(SKTexture(imageNamed: "copterAnimation\(i)"))
        }
        
        copterAnimation = SKAction.repeatActionForever(
            SKAction.animateWithTextures(copterTextures, timePerFrame: 0.1))
        
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        
        //playBackgroundMusic("backgroundMusic.mp3") // Play music
        
        // Create background layer
        backgroundLayer.zPosition = -1 // Set zPosition so that the layer is behind everything else
        addChild(backgroundLayer)
        
        //backgroundColor = SKColor.whiteColor()
        
        // Create 2 background nodes side by side
        /*for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            backgroundLayer.addChild(background)
        }*/
        
        bird.position = CGPoint(x: size.width/2, y: size.height/4)
        bird.zPosition = 100
        copter.zPosition = 100
        bird.setScale(0.5)
        copter.setScale(0.5)
        backgroundLayer.addChild(bird)
        backgroundLayer.addChild(copter)
        
        copter.position = CGPoint(x: bird.position.x, y: bird.position.y + 55.0)

        startBirdAnimation()
        
        /*runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),
                SKAction.waitForDuration(2.0)])))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnCat),
                SKAction.waitForDuration(1.0)])))*/
        
        //debugDrawPlayableArea()
        
    }
    
    func moveBirdToward(location: CGPoint) {
        let offset = location - bird.position
        let direction = offset.normalized()
        velocity = direction * birdMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveBirdToward(touchLocation)
    }
    
    override func touchesBegan(touches: NSSet,
        withEvent event: UIEvent) {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(backgroundLayer)
            sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet,
        withEvent event: UIEvent) {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(backgroundLayer)
            sceneTouched(touchLocation)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - bird.position
            /*if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
            zombie.position = lastTouchLocation!
            velocity = CGPointZero
            stopZombieAnimation()
            } else {*/
            moveSprite(bird, velocity: velocity)
            rotateSprite(bird, direction: velocity * -1, rotateRadiansPerSec: birdRotateRadiansPerSec)
            
            copter.position = CGPoint(x: bird.position.x, y: bird.position.y + 55.0)
            rotateSprite(copter, direction: velocity * -1, rotateRadiansPerSec: birdRotateRadiansPerSec)
            //moveSprite(copter, velocity: velocity)
            
            
            
            //}
        }
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(bird.zRotation, velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func startBirdAnimation() {
        if bird.actionForKey("animation") == nil {
            bird.runAction(
                SKAction.repeatActionForever(birdAnimation),
                withKey: "animation")
        }
        
        if copter.actionForKey("animation") == nil {
            copter.runAction(
                SKAction.repeatActionForever(copterAnimation),
                withKey: "animation")
        }
    }
    
    
}
