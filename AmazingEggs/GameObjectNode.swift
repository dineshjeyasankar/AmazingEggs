//
//  GameObjectNode.swift
//  AmazingEggs
//
//  Created by Dinesh Jeyasankar on 8/26/14.
//  Copyright (c) 2014 Dinesh Jeyasankar. All rights reserved.
//

import Foundation
import SpriteKit

class GameObjectNode : SKNode{
    // Called when a player physics body collides with the game object's physics body
    func collisionWithPlayer(player: SKNode) -> Bool{
         NSLog("collisionWithPlayer in GameObjectNode");
        return false
    }
    // Called every frame to see if the game object should be removed from the scene
    func checkNodeRemoval(playerY: CGFloat){
        if (playerY > self.position.y + 300.0){
            NSLog("checkNodeRemoval in GameObjectNode");
            self.removeFromParent()
        }
    }

}
