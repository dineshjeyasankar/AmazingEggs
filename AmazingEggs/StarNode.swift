//
//  StarNode.swift
//  AmazingEggs
//
//  Created by Dinesh Jeyasankar on 8/26/14.
//  Copyright (c) 2014 Dinesh Jeyasankar. All rights reserved.
//

import Foundation
import SpriteKit


class StarNode : GameObjectNode{
    
    //start Type
    enum StarType:Int{
        case STAR_NORMAL  = 0
        case STAR_SPECIAL = 1
    }
    
    var starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        // Boost the player up
       // player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0)
        //add sound
        self.parent.runAction(starSound)
        // Remove this star
        self.removeFromParent()
        NSLog("collisionWithPlayer");
        return true
    }
    
}
