//
//  GameScene.swift
//  ColorGame
//
//  Created by Jing Wang on 9/26/17.
//  Copyright © 2017 figur8. All rights reserved.
//

import SpriteKit
import GameplayKit


enum Enemies:Int {
    case small
    case medium
    case large
}

class GameScene: SKScene {
    
    //    var tracksArray:[SKSpriteNode]? = [SKSpriteNode]() //By Brian A.
    var tracksArray:[SKSpriteNode]? = [] //By Jing
    var player:SKSpriteNode!
    var currentTrack = 0
    var movingToTrack = false
    var moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    let trackVelocities = [180, 200, 250]
    var directionArray:[Bool] = []
    var velocityArray:[Int] = []
    
    
    func setupTracks() {
        for i in 0...8 {
            if let track = self.childNode(withName: "\(i)") as? SKSpriteNode {
                tracksArray?.append(track)
            }
        }
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        let playerYPos = (tracksArray?.first?.size.height)!/2
        
        
        guard let playerXPos = tracksArray?.first?.position.x else {
            print("Please set up tracks in SKScene")
            return
        }
        
        
        player.position = CGPoint(x: playerXPos, y: playerYPos)
        print("x = \(playerXPos), y = \(playerYPos)")
        self.addChild(player)
        
        let pulse = SKEmitterNode(fileNamed: "pulse")!
        player.addChild(pulse)
        pulse.position = CGPoint(x: 0, y: 0)
        
    }
    
    func createEnemy(type: Enemies, forTrack track:Int) -> SKShapeNode? {
        let enemySprite = SKShapeNode()
        enemySprite.name = "Enemy"
        switch type {
        case .small:
            enemySprite.path = CGPath(roundedRect: CGRect(x:-10, y:0, width:20, height:70), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.4431, green: 0.5529, blue: 0.7451, alpha: 1)
        case .medium:
            enemySprite.path = CGPath(roundedRect: CGRect(x:-10, y:0, width:20, height:100), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1)
        case .large:
            enemySprite.path = CGPath(roundedRect: CGRect(x:-10, y:0, width:20, height:130), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1)
        }
        
        guard let enemyPosition = tracksArray?[track].position else {
            return nil
        }
        
        let up = directionArray[track]
        
        
        
        enemySprite.position.x = enemyPosition.x
        enemySprite.position.y = up ? -130 : self.size.height
            + 130
        enemySprite.physicsBody = SKPhysicsBody(edgeLoopFrom: enemySprite.path!)
        enemySprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        return enemySprite
    }
    
    
    func spwanEnemies() {
        for i in 1...7 {
            let randEnemyType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))
            if let newEnemy = createEnemy(type: randEnemyType!, forTrack: i) {
                self.addChild(newEnemy)
            }
        }
        
        self.enumerateChildNodes(withName: "Enemy"){(node: SKNode, nil) in
            if node.position.y < -150 || node.position.y > self.size.height + 150 {
                node.removeFromParent()
            }
        }
    }
    
    override func didMove(to view: SKView) {
        //        tracksArray?.last?.color = UIColor.green
        //                tracksArray?[4].color = UIColor.green
        setupTracks()
        createPlayer()
        
        if let numberOfTracks = tracksArray?.count{
            for _ in 0...numberOfTracks {
                let randomNumberForVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
                velocityArray.append(trackVelocities[randomNumberForVelocity])
                directionArray.append(GKRandomSource.sharedRandom().nextBool())
            }
        }
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {self.spwanEnemies()}, SKAction.wait(forDuration: 2)])))
        
    }
    
    func moveVertically(up:Bool) {
        if up {
            let moveAction = SKAction.moveBy(x: 0, y: 3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player.run(repeatAction)
        } else {
            let moveAction = SKAction.moveBy(x: 0, y: -3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player.run(repeatAction)
            
        }
    }
    
    func moveToNextTrack() {
        player.removeAllActions()
        movingToTrack = true
        
        guard let nextTrack = tracksArray?[currentTrack + 1].position  else {
            print("Invalid track!")
            return
        }
        
        if let player = self.player {
            let moveAction = SKAction.move(to: CGPoint(x: nextTrack.x, y:player.position.y), duration: 0.2)
            player.run(moveAction, completion: {
                self.movingToTrack = false
            })
            currentTrack = currentTrack + 1
            self.run(moveSound)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if  let touch  = touches.first{
            //            let location = touch.previousLocation(in: self) //BA
            let location = touch.location(in: self) //Jing
            let node = self.nodes(at: location).first
            if node?.name == "right" {
                moveToNextTrack()
                //                print("Move right") //DEBUG
            } else if node?.name == "up" {
                //                print("Move up")//DEBUG
                moveVertically(up: true)
            } else if node?.name == "down" {
                //                print("Move down") //DEBUG
                moveVertically(up: false)
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if movingToTrack == false {
            player.removeAllActions()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.removeAllActions()
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
