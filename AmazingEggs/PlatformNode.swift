//
//  PlatformNode.swift
//  AmazingEggs
//
//  Created by Dinesh Jeyasankar on 8/26/14.
//  Copyright (c) 2014 Dinesh Jeyasankar. All rights reserved.
//

import Foundation
import SpriteKit

class PlatformNode : GameObjectNode{
    
    enum PlatformType:Int{
        case PLATFORM_NORMAL  = 1
        case PLATFORM_BREAK = 2
    }
    
    var platformType = PlatformType.PLATFORM_NORMAL
    
    override func collisionWithPlayer(player: SKNode) -> Bool {

        // Only bounce the player if he's falling
        if (player.physicsBody.velocity.dy < 0) {
            // give the player node a vertical boost to make it bounce off the platform
            //player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 45.0)
            // add collisionBitMask of platform to player shld remove on bounce
            player.physicsBody.collisionBitMask = GameScene.ColliderType.CollisionCategoryPlatform.toRaw()

            // Remove if it is a Break type platform
            if (self.platformType == PlatformType.PLATFORM_BREAK) {
                self.removeFromParent()
            }
        }
        
        // 4
        // No stars for platforms
        return false
    }
}
