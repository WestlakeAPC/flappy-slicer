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

    // MARK: Game Control
    var birdSpeed = 60
    var birdControl: Int = 101
    
    var swordSpeed: CGFloat = 80
    var swordUpdateTime = 0.1

    // MARK: Sounds
    var punchSoundEffect = AVAudioPlayer()

    // MARK: Variables
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

    // MARK: When the view loads
    override func didMove(to view:SKView) {
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
        self.backgroundImage = self.childNode(withName: "backgroundImage") as? SKSpriteNode
        let backgroundPhoto = SKTexture(imageNamed: "backgroundphoto.png")
        backgroundImage = SKSpriteNode(texture: backgroundPhoto)
        backgroundImage?.size.height = self.size.height
        backgroundImage?.size.width = self.size.height * 900 / 504
        backgroundImage?.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        backgroundImage?.zPosition = -5
        self.addChild(backgroundImage!)
        
        self.charc = self.childNode(withName: "Bro") as? SKSpriteNode
        charc?.name = "Bro"
        charc?.position = CGPoint(x: self.frame.size.width / 10, y: self.frame.size.height / 2)
        charc?.zPosition = 1
        charc?.physicsBody = SKPhysicsBody(rectangleOf: (charc?.size)!)
        charc?.xScale = 0.8
        charc?.yScale = 0.8
        charc?.zPosition = 20
        
        self.shootButton = self.backgroundImage?.childNode(withName: "shootButton") as? SKSpriteNode
        
        
        self.fireLabel = self.shootButton?.childNode(withName: "fireLabel") as? SKLabelNode
        

        // Punch sound
        let punchSound = URL(fileURLWithPath: Bundle.main.path(forResource: "punch", ofType: "wav")!)
        punchSoundEffect = try! AVAudioPlayer.init(contentsOf: punchSound)
        punchSoundEffect.prepareToPlay()
        punchSoundEffect.numberOfLoops = 0

        //Screen Boarder
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
    override func touchesEnded(_ touches:Set<UITouch>, with event:UIEvent?) {
        buttonTapped = false

        for touch in touches {

            for i in self.nodes(at: touch.location(in: self)) {
                if i.name == "Fire!" {
                    buttonTapped = true
                    fireSwords(charcLocation: (self.charc?.position)!)
                }
            }
            moveCharc(touch)
        }
    }

    // MARK: Move character
    func moveCharc(_ touch :UITouch) {
        if (touch.location(in: self).y > self.frame.size.height / 2) {
            if (!buttonTapped) {
                if !((self.charc?.position.y)! + (self.charc?.size.height)! / 2 >= self.size.height) {
                    self.charc?.run(self.moveUp)
                }
            }
        } else if (touch.location(in: self).y <= self.frame.size.height / 2) {
            if (!buttonTapped) {
                if !((self.charc?.position.y)! - (self.charc?.size.height)! / 2 <= 0) {
                    self.charc?.run(self.moveDown)
                }
            }
        }
    }
    
    
    // MARK: Fire swords
    func fireSwords(charcLocation charcPos:CGPoint) {
        let theSwordLook = SKTexture(imageNamed: "the_other_sword.png")
        let aSword = SKSpriteNode(texture: theSwordLook)
        aSword.position = CGPoint(x: charcPos.x + 40, y: charcPos.y - 25)
        aSword.zPosition = 3
        aSword.xScale = 0.5
        aSword.yScale = 0.5
        swordsArray.append(aSword)

        let moveSword = SKAction.repeat(SKAction.moveBy(x: swordSpeed, y: 0, duration: swordUpdateTime), count: Int(self.size.width / swordSpeed))
        let swordSequence = SKAction.sequence([moveSword, SKAction.removeFromParent()])
        aSword.run(swordSequence, completion: { self.removeFirstSwordFromArray() })
        self.addChild(aSword)
    }

    // MARK: Used to add birds and detect collision
    override func update(_ currentTime:TimeInterval) {
        // The array for  birds that were hit
        var birdRemovalArray = [Int?](repeating: nil, count: 0)

        // Collision Check
        if (birdArray.count >= 1 && swordsArray.count >= 1) {
            for i in 0 ... birdArray.count - 1 {
                for j in 0 ... swordsArray.count - 1 {
                    let selectedBird = birdArray[i]
                    let selectedSword = swordsArray[j]

                    if ((!(selectedBird == nil) && !(selectedSword == nil)) && (!(swordsArray.count == 0) && !(birdArray.count == 0))) {
                        if ((selectedBird?.intersects(selectedSword!))! == true) {

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

        // Remove birds from array
        if !(birdRemovalArray.count == 0) {
            for k in 0 ... birdRemovalArray.count - 1 {
                //print("Inside for loop.")
                if !(birdRemovalArray[birdRemovalArray.count - k - 1] == nil) {
                    killSelectedBirdFromArray(selectedBirdIndex: birdRemovalArray[birdRemovalArray.count - k - 1]!)
                }
            }
        }

        // Send Birds
        let NewBird = Int(arc4random() % 100)
        if (NewBird <= birdControl) {

            let theFirstBirdSkin = SKTexture(imageNamed: "High Winged Bird.png")
            let theSecondBirdSkin = SKTexture(imageNamed: "Low Winged Bird.png")
            let aBird = SKSpriteNode(texture: theFirstBirdSkin)

            let birdFlapWings = SKAction.repeatForever(SKAction.animate(with: [theFirstBirdSkin, theSecondBirdSkin], timePerFrame: 0.1))
            let moveTheBird = SKAction.repeat(SKAction.moveBy(x: -1 * CGFloat(birdSpeed), y: 0, duration: 0.2),
                                              count: (Int(self.size.width + aBird.size.width * 5)) / birdSpeed)
            let birdSequence = SKAction.sequence([moveTheBird, SKAction.removeFromParent()])

            let randomBirdPosY = arc4random() % UInt32(self.size.height * 7 / 8)
            aBird.position = CGPoint(x: self.size.width + (aBird.size.width) * 2, y: CGFloat(randomBirdPosY))
            aBird.zPosition = 4
            birdArray.append(aBird)

            aBird.run(birdFlapWings)
            aBird.run(birdSequence, completion: { self.removeFirstBirdFromArray() })
            aBird.run(SKAction.scale(to: 0.1, duration: 1.5))

            self.addChild(aBird)
        }
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
    func killSelectedBirdFromArray(selectedBirdIndex Index:Int) -> Void {
        let birdFall = SKAction.repeat(SKAction.moveBy(x: 0, y: CGFloat(-3 * birdSpeed), duration: 0.1), count: (Int((1.2 * (birdArray[Index]?.position.y)!)) / (2 * birdSpeed)))
        let birdDeathSequence = SKAction.sequence([birdFall, SKAction.removeFromParent()])

        self.birdArray[Index]?.run(birdDeathSequence)
        self.birdArray.remove(at: Index)
    }

    // MARK: Sword nerfing (not yet used)
    func swordCollision(theSword targetSword:SKSpriteNode) -> Void {
        targetSword.run(SKAction.removeFromParent())
    }

}
