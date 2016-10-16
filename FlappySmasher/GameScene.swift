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

    //Game Control
    var birdSpeed = 60
    var additionalSpeedLimit = 30
    var birdControl: Int = 101
    //The percentage of bird spwning
    
    var swordSpeed: CGFloat = 80
    var swordUpdateTime = 0.1
    var gameScore = 0

    //Sounds
    var punchSoundEffect = AVAudioPlayer()

    //Varibles
    var buttonTapped = false
    var reportTaps = false

    //Array
    var swordsArray = [SKSpriteNode?](repeating: nil, count: 0)
    var birdArray = [SKSpriteNode?](repeating: nil, count: 0)

    //Sprites
    var charc = SKSpriteNode()
    var fireLabel = SKLabelNode()
    var shootButton = SKShapeNode()
    var displayScore = SKLabelNode()
    var backgroundImage = SKSpriteNode()

    //Actions
    var moveUp = SKAction.moveBy(x: 0, y: 120, duration: 0.3)
    var moveDown = SKAction.moveBy(x: 0, y: -120, duration: 0.3)

    //When the view loads
    override func didMove(to view:SKView) {
        /* Setup your scene here */

        //Debug Information
        print("Scene Dimensions")
        print(self.size.width)
        print(self.size.height)
        print("Screen Dimensions")
        print(UIScreen.main.bounds.width * 2)
        print(UIScreen.main.bounds.height * 2)

        //Matching Dimensions
        self.size.width = UIScreen.main.bounds.width * 2
        self.size.height = UIScreen.main.bounds.height * 2

        //   ---Graphics Initialization---
        //Background Image
        let backgroundPhoto = SKTexture(imageNamed: "backgroundphoto.png")
        backgroundImage = SKSpriteNode(texture: backgroundPhoto)
        backgroundImage.size.height = self.size.height
        backgroundImage.size.width = self.size.height * 900 / 504
        backgroundImage.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        backgroundImage.zPosition = -5
        self.addChild(backgroundImage)

        //Jim Charc
        let charcLook = SKTexture(imageNamed: "final-charc.png")
        self.charc = SKSpriteNode(texture: charcLook)
        charc.name = "Bro"
        charc.position = CGPoint(x: self.frame.size.width / 10, y: self.frame.size.height / 2)
        charc.zPosition = 1
        charc.physicsBody = SKPhysicsBody(rectangleOf: charc.size)
        charc.xScale = 0.8
        charc.yScale = 0.8
        charc.zPosition = 20
        self.addChild(charc)

        //Shoot Button
        self.shootButton.path = UIBezierPath(roundedRect: CGRect(x: -125, y: -50, width: 250, height: 100), cornerRadius: 32).cgPath
        self.shootButton.position = CGPoint(x: self.size.width * 13 / 16, y: self.size.height * 1 / 4)
        self.shootButton.zPosition = 2
        self.shootButton.fillColor = UIColor.white
        self.shootButton.name = "Fire!"
        self.addChild(shootButton)

        //Fire Label
        self.fireLabel.text = "Fire!"
        self.fireLabel.position = CGPoint(x: 0, y: -10)
        self.fireLabel.zPosition = 0
        self.fireLabel.fontSize = 40
        self.fireLabel.fontColor = UIColor.red
        self.fireLabel.fontName = "System"
        shootButton.addChild(fireLabel)
        
        //Add Score Board
        self.displayScore.text = "0"
        self.displayScore.position = CGPoint(x: self.size.width/2, y: self.size.height - 120)
        self.displayScore.fontSize = 120
        
        self.addChild(self.displayScore)

        //   ---Sound Effects Setup---
        //Punch sound
        //Sword Sound
        let punchSound = URL(fileURLWithPath: Bundle.main.path(forResource: "punch", ofType: "wav")!)
        punchSoundEffect = try! AVAudioPlayer.init(contentsOf: punchSound)
        punchSoundEffect.prepareToPlay()
        punchSoundEffect.numberOfLoops = 0

        //Screen Boarder
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

    }

    //When the screen is tapped    //Used to report tapped coordinates
    override func touchesBegan(_ touches:Set<UITouch>, with event:UIEvent?) {
        /* Called when a touch begins */

        for touch in touches {
            if reportTaps {
                print("Tap Location" + String(describing: touch.location(in: self)))

            }
        }
    }

    //When screen tapped is lifted    //Triggers moveCharc and fireSwords
    override func touchesEnded(_ touches:Set<UITouch>, with event:UIEvent?) {
        buttonTapped = false

        for touch in touches {

            for i in self.nodes(at: touch.location(in: self)) {
                if i.name == "Fire!" {
                    buttonTapped = true
                    fireSwords(charcLocation: self.charc.position)
                }
            }
            moveCharc(UserInput: touch)
        }
    }

    //Move the charc
    func moveCharc(UserInput touch :UITouch) {
        if (touch.location(in: self).y > self.frame.size.height / 2) {
            if (!buttonTapped) {
                if !(self.charc.position.y + self.charc.size.height / 2 >= self.size.height) {
                    self.charc.run(self.moveUp)
                }
            }
        } else if (touch.location(in: self).y <= self.frame.size.height / 2) {
            if (!buttonTapped) {
                if !(self.charc.position.y - self.charc.size.height / 2 <= 0) {
                    self.charc.run(self.moveDown)
                }
            }
        } else {
            print("T_T")
        }
    }

    //Fire Swords
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

    //Updates before each frame renders    //Used to add birds and detect collision
    override func update(_ currentTime:TimeInterval) {
        //The array for  birds that were hit
        var birdRemovalArray = [Int?](repeating: nil, count: 0)

        //Collision Check
        if (birdArray.count >= 1 && swordsArray.count >= 1) {
            for i in 0 ... birdArray.count - 1 {
                for j in 0 ... swordsArray.count - 1 {
                    let selectedBird = birdArray[i]
                    let selectedSword = swordsArray[j]

                    if ((!(selectedBird == nil) && !(selectedSword == nil)) && (!(swordsArray.count == 0) && !(birdArray.count == 0))) {
                        if ((selectedBird?.intersects(selectedSword!))! == true) {

                            punchSoundEffect.play()

                            //print("Bird array length before collision:" + String(birdArray.count))

                            if (birdRemovalArray.count > 0) {
                                //Checks for repeating valuse
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

        //Remove birds from array
        if !(birdRemovalArray.count == 0) {
            for k in 0 ... birdRemovalArray.count - 1 {
                //print("Inside for loop.")
                if !(birdRemovalArray[birdRemovalArray.count - k - 1] == nil) {
                    KillSelectedBirdFromArray(selectedBirdIndex: birdRemovalArray[birdRemovalArray.count - k - 1]!)
                }
            }
        }

        //Send Birds
        let NewBird = Int(arc4random() % 100)
        if (NewBird <= birdControl) {

            let theFirstBirdSkin = SKTexture(imageNamed: "High Winged Bird.png")
            let theSecondBirdSkin = SKTexture(imageNamed: "Low Winged Bird.png")
            let aBird = SKSpriteNode(texture: theFirstBirdSkin)
            
            aBird.xScale = 0.125
            aBird.yScale = 0.125

            let birdFlapWings = SKAction.repeatForever(SKAction.animate(with: [theFirstBirdSkin, theSecondBirdSkin], timePerFrame: 0.1))
            
            let additionalBirdSpeed = CGFloat(arc4random() % UInt32(self.additionalSpeedLimit))
            let moveTheBird = SKAction.repeat(SKAction.moveBy(x: -1 * (CGFloat(birdSpeed) + additionalBirdSpeed), y: 0, duration: 0.2), count: (Int(self.size.width + aBird.size.width * 5)) / birdSpeed)
            let birdSequence = SKAction.sequence([moveTheBird, SKAction.removeFromParent()])

            let randomBirdPosY = arc4random() % UInt32(self.size.height * 7 / 8)
            aBird.position = CGPoint(x: self.size.width + (aBird.size.width) * 2, y: CGFloat(randomBirdPosY))
            aBird.zPosition = 4
            birdArray.append(aBird)
            print("Bird array length:" + String(birdArray.count))

            aBird.run(birdFlapWings)
            aBird.run(birdSequence, completion: { self.removeFirstBirdFromArray() })

            self.addChild(aBird)
        }
    }

    //Remove first bird
    func removeFirstBirdFromArray() -> Void {
        birdArray.remove(at: 0)
    }

    //Remove first sword
    func removeFirstSwordFromArray() -> Void {
        swordsArray.remove(at: 0)
    }

    //Kill the bird that was hit
    func KillSelectedBirdFromArray(selectedBirdIndex Index:Int) -> Void {
        print("Bird array length before remove:" + String(birdArray.count))
        print("Selected bird index:" + String(Index))
        let birdFall = SKAction.repeat(SKAction.moveBy(x: 0, y: CGFloat(-3 * birdSpeed), duration: 0.1), count: (Int((1.2 * (birdArray[Index]?.position.y)!)) / (2 * birdSpeed)))
        let birdDeathSequence = SKAction.sequence([birdFall, SKAction.removeFromParent()])

        self.birdArray[Index]?.run(birdDeathSequence)
        self.birdArray.remove(at: Index)

        print("Bird array length after remove:" + String(birdArray.count))
        
        //Add score
        self.gameScore = self.gameScore + 1
        self.displayScore.text = String(self.gameScore)
        
    }

    //Sword Nerfing (Not yet used) -!-
    func swordCollision(theSword targetSword:SKSpriteNode) -> Void {
        targetSword.run(SKAction.removeFromParent())
    }

}
