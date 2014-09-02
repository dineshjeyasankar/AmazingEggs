//
//  GameScene.swift
//  AmazingEggs
//
//  Created by Dinesh Jeyasankar on 8/25/14.
//  Copyright (c) 2014 Dinesh Jeyasankar. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var backgroundNode = SKNode()
    var playerNode = SKNode()
    var hudNode = SKNode()
    var foregroundNode = SKNode()
    var midgroundNode = SKNode()
    
    
    var touching = false
    
    let PLAYER_SPEED = CGFloat(30.0)
    
    
    //define Collision Category
    enum ColliderType:UInt32 {
        case CollisionCategoryPlayer    = 1
        case CollisionCategoryStar      = 2
        case CollisionCategoryPlatform  = 4
    }
    
    // MARK: Game Setup
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        setup()
    }
    
    func setup() {
        //create backgroundNode
        // Go through images until the entire background is built
        for(var nodeCount = 0; nodeCount < 20; nodeCount++) {
            var backgroundImageName = NSString(format: "Background%02d", nodeCount+1)
            var node = SKSpriteNode(imageNamed: backgroundImageName)
            //image size was small, so set it to scene size
            node.size.width=self.frame.size.width
            node.anchorPoint = CGPointMake(0.5, 0.5)
            //stack in 64-point-tall
            node.position = CGPointMake(CGFloat(self.frame.size.width/2),CGFloat(nodeCount*64.0))
            self.backgroundNode.addChild(node)
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        // A simple white screen
        self.backgroundColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        //add some gravity
        self.physicsWorld.gravity = CGVectorMake(0.0, -2.0)
        // Set contact delegate
        self.physicsWorld.contactDelegate = self
        
        
        
        
        //read the plist
        let levelPlist = NSBundle.mainBundle().pathForResource("Level01", ofType: "plist")
        let levelData = NSDictionary(contentsOfFile: levelPlist!)
        println(levelData)
        // Height at which the player ends the level
        let endLevelY: AnyObject = levelData.objectForKey("EndY")!
        println(endLevelY)
        let platforms: AnyObject = levelData.objectForKey("Platforms")!
        println("**platforms**")
        println(platforms)
        println("**platforms**")
        let platformPatterns  = platforms.objectForKey("Patterns") as NSDictionary
        println("**platformPatterns**")
        println(platformPatterns)
        println("**platformPatterns**")
        let platformPositions = platforms.objectForKey("Positions") as NSArray
        println("**platformPositions**")
        println(platformPositions)
        println("**platformPositions**")
        // Add the platforms
        for platformPosition in platformPositions{
            var patternX = platformPosition["x"] as CGFloat
            println(patternX)
            var patternY = platformPosition["y"] as CGFloat
            println(patternY)
            var pattern = platformPosition["pattern"] as NSString
            println(pattern)
            // Look up the pattern
            var platformPattern = platformPatterns[pattern] as NSArray
            println("**platformPattern**")
            println(platformPattern)
            println("**platformPattern**")
            for item in platformPattern{
                var platformPoint = item as NSDictionary
                println("**platformPoint**")
                println(platformPoint)
                println("**platformPoint**")
                var x = platformPoint["x"] as CGFloat
                println(x)
                var y = platformPoint["y"] as CGFloat
                println(y)
                var ptype=platformPoint["type"] as Int
                println(ptype)
                var platfrom = PlatformNode()
                platfrom = createPlatformAtPosition(CGPointMake(x+patternX*2, y+patternY),
                    type: PlatformNode.PlatformType.fromRaw(ptype)!)
                self.foregroundNode.addChild(platfrom)
            }
            
        }
        
        let stars: AnyObject = levelData.objectForKey("Stars")!
        println("**stars**")
        println(stars)
        println("**stars**")
        let starPatterns  = stars.objectForKey("Patterns") as NSDictionary
        println("**starPatterns**")
        println(starPatterns)
        println("**starPatterns**")
        let starPositions = stars.objectForKey("Positions") as NSArray
        println("**starPositions**")
        println(starPositions)
        println("**starPositions**")
        // Add the stars
        for starPosition in starPositions{
            var patternX = starPosition["x"] as CGFloat
            println(patternX)
            var patternY = starPosition["y"] as CGFloat
            println(patternY)
            var pattern = starPosition["pattern"] as NSString
            println(pattern)
            // Look up the pattern
            var starPattern = starPatterns[pattern] as NSArray
            println("**starPattern**")
            println(starPattern)
            println("**starPattern**")
            for item in starPattern{
                var starPoint = item as NSDictionary
                println("**starPoint**")
                println(starPoint)
                println("**starPoint**")
                var x = starPoint["x"] as CGFloat
                println(x)
                var y = starPoint["y"] as CGFloat
                println(y)
                var stype = starPoint["type"] as Int
                println(stype)
                var star = StarNode()
                star = createStarAtPosition(CGPointMake(x + patternX*2,  y + patternY), type: StarNode.StarType.fromRaw(stype)!)
                self.foregroundNode.addChild(star)
            }
            
        }
        
        // create midgroundNode
        self.midgroundNode = createMidgroundNode()
        
        
        //create player
        self.playerNode = SKSpriteNode(imageNamed: "Player")
        //position player
        self.playerNode.position=CGPointMake(CGFloat(size.width/2), CGFloat(80.0))
        //  physics body needs a shape
        self.playerNode.physicsBody = SKPhysicsBody(circleOfRadius: self.playerNode.frame.width/2)
        // affected by forces and impulses
        self.playerNode.physicsBody.dynamic = false
        // No Rotation. Later need to change for egg
        self.playerNode.physicsBody.allowsRotation = false
        // Since we’re handling collisions
        self.playerNode.physicsBody.restitution = 0.0
        self.playerNode.physicsBody.friction = 0.0
        self.playerNode.physicsBody.angularDamping = 0.0
        self.playerNode.physicsBody.linearDamping = 0.0
        
        // as accurate as possible!
        self.playerNode.physicsBody.usesPreciseCollisionDetection = true
        // It belongs to the CollisionCategoryPlayer
        self.playerNode.physicsBody.categoryBitMask = ColliderType.CollisionCategoryPlayer.toRaw()
        // don’t want physics engine to simulate any collisions
        self.playerNode.physicsBody.collisionBitMask = 0
        // want to be informed when the player node touches any stars or platforms.
        self.playerNode.physicsBody.contactTestBitMask = ColliderType.CollisionCategoryStar.toRaw() | ColliderType.CollisionCategoryPlatform.toRaw()
        
        self.foregroundNode.addChild(self.playerNode)
        
        // create hudNode for tap to start
        self.hudNode = SKSpriteNode(imageNamed: "TapToStart")
        self.hudNode.position = CGPointMake(CGFloat(size.width/2), CGFloat(180))
        
        
        
        //add backgroundNode
        self.addChild(self.backgroundNode)
        //add midgroundNode
        self.addChild(midgroundNode)
        //add Player foregroundNode
        self.addChild(self.foregroundNode)
        //add tap to start
        self.addChild(self.hudNode)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        self.touching = true
        // If we're already playing, ignore touches
        // if(self.playerNode.physicsBody.dynamic){
        //      return
        //  }else{
        // Remove the Tap to Start node
        self.hudNode.removeFromParent()
        // Start the player by putting them into the physics simulation
        self.playerNode.physicsBody.dynamic = true
        //apply Impulse to move the body
        //self.playerNode.physicsBody.velocity = CGVectorMake(0.0, 400.0)
        self.playerNode.physicsBody.applyImpulse(CGVectorMake(0.0, self.PLAYER_SPEED))
        // when we apply impulse make the collisionBitMask to 0
        self.playerNode.physicsBody.collisionBitMask = 0
        //   }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.touching = false
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if (self.playerNode.position.y > 200.0) {
            self.backgroundNode.position = CGPointMake(0.0, -((self.playerNode.position.y - 200.0)/10));
            self.midgroundNode.position = CGPointMake(0.0, -((self.playerNode.position.y - 200.0)/4));
            self.foregroundNode.position = CGPointMake(0.0, -(self.playerNode.position.y - 200.0));
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var updateHUD = false
        var other = GameObjectNode()
        if (contact.bodyA.node != self.playerNode){
            other = contact.bodyA.node as GameObjectNode
        }else{
            other = contact.bodyB.node as GameObjectNode
        }
        updateHUD = other.collisionWithPlayer(self.playerNode)
        // Update the HUD if necessary
        if (updateHUD) {
            // 4 TODO: Update HUD in Part 2
        }
    }
    
    //Method to create start @ position
    func createStarAtPosition(position: CGPoint, type: StarNode.StarType)->StarNode{
        //create and instantiate node
        var node = StarNode()
        var sprite = SKSpriteNode()
        node.position = position
        node.name = "NODE_STAR"
        //assign start graphics
        if(type == StarNode.StarType.STAR_SPECIAL){
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        }else{
            sprite = SKSpriteNode(imageNamed: "Star")
        }
        
        //add sprite to the node
        node.addChild(sprite)
        //for collision detection
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.frame.width/2)
        //physics body static, because we don’t want gravity
        node.physicsBody.dynamic = false
        //assign the star’s Collision category
        node.physicsBody.categoryBitMask = ColliderType.CollisionCategoryStar.toRaw()
        //Sprite Kit won’t notify me when something touches the star
        node.physicsBody.collisionBitMask = 0
        return node
    }
    
    //method to create platform
    func createPlatformAtPosition(position: CGPoint, type: PlatformNode.PlatformType)->PlatformNode{
        var node = PlatformNode()
        var sprite = SKSpriteNode()
        node.position = position
        node.name = "NODE_PLATFORM"
        //assign platfrom graphics
        if(type == PlatformNode.PlatformType.PLATFORM_BREAK){
            sprite = SKSpriteNode(imageNamed: "PlatformBreak")
        }else{
            sprite = SKSpriteNode(imageNamed: "Platform")
        }
        //add sprite to the node
        node.addChild(sprite)
        //for collision detection
        //node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.frame.width/2)
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sprite.frame.width, sprite.frame.height))
        //physics body static, because we don’t want gravity
        node.physicsBody.dynamic = false
        //assign the platforms’s Collision category
        node.physicsBody.categoryBitMask = ColliderType.CollisionCategoryPlatform.toRaw()
        //Sprite Kit won’t notify me when something touches the platform
        //node.physicsBody.collisionBitMask = 0
        //
        node.physicsBody.restitution = 0.0
        return node
    }
    
    func createMidgroundNode() -> SKNode{
        var midgroundNode = SKNode()
        var spriteName: String
        //add ten branches to midgroundNode
        for index in 1...10 {
            var r = arc4random() % 2
            if ( r > 0){
                spriteName = "BranchRight"
            }else{
                spriteName = "BranchLeft"
            }
            var branchNode = SKSpriteNode(imageNamed: spriteName)
            //space the branches at 500-point intervals on the y-axis of the midground node
            branchNode.position = CGPointMake(CGFloat(450.0),CGFloat(500.0 * index))
            midgroundNode.addChild(branchNode)
        }
        return midgroundNode
    }
    
    
}
