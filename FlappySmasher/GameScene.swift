//
//  GameScene.swift
//  FlappySmasher
//
//  Created by Joseph Jin on 8/11/16.
//  Copyright (c) 2016 Animator Joe. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {

    // MARK: Game control
    var birdSpeed = 60
    var birdControl: Int = 101
    
    var swordSpeed: CGFloat = 120
    var swordUpdateTime = 0.1

    // MARK: Sounds
    var punchSoundEffect = AVAudioPlayer()

    // MARK: Debug variables
    var buttonTapped = false
    var reportTaps = false

    // MARK: Array
    var swordsArray = [SKSpriteNode?](repeating: nil, count: 0)
    var birdArray = [SKSpriteNode?](repeating: nil, count: 0)

    // MARK: Sprites
    var charc: SKSpriteNode?
    var fireLabel: SKLabelNode?
    var shootButton: SKSpriteNode?
    var backgroundImage: SKSpriteNode?

    // MARK: Actions
    var moveUp = SKAction.moveBy(x: 0, y: 120, duration: 0.3)
    var moveDown = SKAction.moveBy(x: 0, y: -120, duration: 0.3)
    
    // MARK: When view loads
    override func didMove(to view: SKView) {
        // Debug information
        print("Scene Dimensions")
        print(self.size.width)
        print(self.size.height)
        print("Screen Dimensions")
        print(UIScreen.main.bounds.width * 2)
        print(UIScreen.main.bounds.height * 2)

        // Matching dimensions
        self.size.width = UIScreen.main.bounds.width * 2
        self.size.height = UIScreen.main.bounds.height * 2
        
        // Aggregate sprites.
        self.backgroundImage = self.childNode(withName: "//backgroundImage") as? SKSpriteNode
        backgroundImage?.size.height = self.size.height
        backgroundImage?.size.width = self.size.height * 900 / 504
        backgroundImage?.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        self.charc = backgroundImage?.childNode(withName: "//Bro") as? SKSpriteNode
        self.shootButton = self.backgroundImage?.childNode(withName: "//shootButton") as? SKSpriteNode
        self.fireLabel = self.shootButton?.childNode(withName: "//fireLabel") as? SKLabelNode
        
        // Punch sound
        let punchSound = URL(fileURLWithPath: Bundle.main.path(forResource: "punch", ofType: "wav")!)
        punchSoundEffect = try! AVAudioPlayer.init(contentsOf: punchSound)
        punchSoundEffect.prepareToPlay()
        punchSoundEffect.numberOfLoops = 0

        // Screen Border
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }

    // MARK: When the screen is tapped
    override func touchesBegan(_ touches:Set<UITouch>, with event:UIEvent?) {
        /* Called when a touch begins */

        for touch in touches {
            if reportTaps {
                print("Tap Location" + String(describing: touch.location(in: self)))

            }
        }
    }

    // MARK: Triggers moveCharc and fireSwords
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonTapped = false

        for touch in touches {
            for i in self.nodes(at: touch.location(in: self)) {
                if i.name == "shootButton" {
                    buttonTapped = true
                    fireSwords(location: (self.charc?.position)!)
                }
            }
            
            moveCharc(touch)
        }
    }

    // MARK: Move character
    func moveCharc(_ touch: UITouch) {
        if (touch.location(in: self).y > self.frame.size.height / 2) {
            if (!buttonTapped) {
                self.charc?.run(self.moveUp)
            }
        } else if (touch.location(in: self).y <= self.frame.size.height / 2) {
            if (!buttonTapped) {
                self.charc?.run(self.moveDown)
            }
        }
    }
    
    
    // MARK: Fire swords
    func fireSwords(location charcPos: CGPoint) {
        let swordTexture = SKTexture(imageNamed: "the_other_sword.png")
        let sword = SKSpriteNode(texture: swordTexture)
        sword.position = CGPoint(x: charcPos.x + 60, y: charcPos.y)
        sword.zPosition = 3
        sword.xScale = 0.5
        sword.yScale = 0.5
        swordsArray.append(sword)

        let moveSword = SKAction.repeat(SKAction.moveBy(x: swordSpeed, y: 0, duration: swordUpdateTime), count: Int(self.size.width / swordSpeed))
        let swordSequence = SKAction.sequence([moveSword, SKAction.removeFromParent()])
        sword.run(swordSequence, completion: self.removeFirstSwordFromArray )
        backgroundImage?.addChild(sword)
    }

    // MARK: Used to add birds and detect collision
    override func update(_ currentTime: TimeInterval) {
        // The array for  birds that were hit
        var birdRemovalArray = [Int](repeating: 0, count: 0)

        // Collision check
        if (birdArray.count >= 1 && swordsArray.count >= 1) {
            for i in 0 ..< birdArray.count {
                for j in 0 ..< swordsArray.count {
                    if let selectedBird = birdArray[i] {
                        if let selectedSword = swordsArray[j] {
                            if !(swordsArray.count == 0) && !(birdArray.count == 0) {
                                if selectedBird.intersects(selectedSword) {
                                    punchSoundEffect.play()

                                    if (birdRemovalArray.count > 0) {
                                        // Checks for repeating values
                                        if !(birdRemovalArray[birdRemovalArray.count - 1] == i) {
                                            birdRemovalArray.append(i)
                                        }
                                    } else {
                                        birdRemovalArray.append(i)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Remove birds from array
        if !(birdRemovalArray.count == 0) {
            for index in birdRemovalArray {
                killSelectedBird(atIndex: index)
            }
        }
        
        // Send birds
        let firstBirdSkin = SKTexture(imageNamed: "High Winged Bird.png")
        let secondBirdSkin = SKTexture(imageNamed: "Low Winged Bird.png")
        let bird = SKSpriteNode(texture: firstBirdSkin)
        
        let flapWings = SKAction.repeatForever(SKAction.animate(with: [firstBirdSkin, secondBirdSkin], timePerFrame: 0.1))
        let moveBird = SKAction.repeat(SKAction.moveBy(x: -1 * CGFloat(birdSpeed), y: 0, duration: 0.2),
                                       count: (Int(self.size.width + bird.size.width * 5)) / birdSpeed)
        let birdSequence = SKAction.sequence([moveBird, SKAction.removeFromParent()])

        let randomBirdPosY = arc4random_uniform(UInt32(self.size.height * 7 / 8))
        bird.position = CGPoint(x: self.size.width + (bird.size.width) * 2, y: CGFloat(randomBirdPosY))
        bird.zPosition = 4
        birdArray.append(bird)

        bird.run(flapWings)
        bird.run(birdSequence, completion: self.removeFirstBirdFromArray)
        bird.run(SKAction.scale(to: 0.1, duration: 1.5))

        backgroundImage?.addChild(bird)
    }

    // MARK: Remove first bird
    func removeFirstBirdFromArray() -> Void {
        birdArray.remove(at: 0)
    }

    // MARK: Remove first sword
    func removeFirstSwordFromArray() -> Void {
        swordsArray.remove(at: 0)
    }

    // MARK: Kill the bird that was hit
    func killSelectedBird(atIndex index: Int) -> Void {
        let birdFall = SKAction.repeat(SKAction.moveBy(x: 0, y: CGFloat(-3 * birdSpeed), duration: 0.1),
                                       count: (Int((1.2 * (birdArray[index]?.position.y)!)) / (2 * birdSpeed)))
        let birdDeathSequence = SKAction.sequence([birdFall, SKAction.removeFromParent()])

        self.birdArray[index]?.run(birdDeathSequence)
        self.birdArray.remove(at: index)
    }
}
