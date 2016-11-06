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
    var birdControl: Int = 2
    //The percentage of bird spwning
    
    var swordSpeed: CGFloat = 80
    var swordUpdateTime = 0.1
    var gameScore = 0

    //Sounds
    var punchSoundEffect = AVAudioPlayer()
    var gunSoundEffect = AVAudioPlayer()

    //Varibles
    var childFriendly = false
    var buttonTapped = false
    var reportTaps = false
    var death = false

    //Array
    var swordsArray = [SKSpriteNode?](repeating: nil, count: 0)
    var birdArray = [SKSpriteNode?](repeating: nil, count: 0)

    //Sprites
    var charc = SKSpriteNode()
    var shootButton = SKSpriteNode()
    var deathlogScreen = SKShapeNode()
    var backgroundImage = SKSpriteNode()
    
    var displayScore = SKLabelNode()
    var deathMessage = SKLabelNode()
    var restartButton = SKLabelNode()
    var deathScoreReport = SKLabelNode()
    
    var charcLook = SKTexture()

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

        //MARK:   ---Graphics Initialization---
        //Background Image
        let backgroundPhoto = SKTexture(imageNamed: "CastleBackground.png")
        backgroundImage = SKSpriteNode(texture: backgroundPhoto)
        backgroundImage.size.height = self.size.height
        backgroundImage.size.width = self.size.height * 900 / 504
        backgroundImage.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        backgroundImage.zPosition = -5
        self.addChild(backgroundImage)

        //Jim Charc
        if (childFriendly) {self.charcLook = SKTexture(imageNamed: "final-charc.png")}
        if (!childFriendly) {self.charcLook = SKTexture(imageNamed: "JimCharc")}
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
        self.shootButton = SKSpriteNode(texture: SKTexture(imageNamed: "fireButton"))
        self.shootButton.position = CGPoint(x: self.size.width * 13 / 16, y: self.size.height * 1 / 4)
        self.shootButton.zPosition = 2
        self.shootButton.xScale = 0.35
        self.shootButton.yScale = 0.35
        self.shootButton.name = "Fire!"
        self.addChild(shootButton)
        
        //Add Score Board
        self.displayScore.text = "0"
        self.displayScore.position = CGPoint(x: self.size.width/2, y: self.size.height - 120)
        self.displayScore.fontSize = 120
        self.addChild(self.displayScore)
        
        //Death Log
        self.deathlogScreen.path = UIBezierPath(roundedRect: CGRect(x: -self.size.width/6, y: -self.size.height/4, width: self.size.width/3, height: self.size.height/2), cornerRadius: 32).cgPath
        self.deathlogScreen.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.deathlogScreen.zPosition = 5
        self.deathlogScreen.fillColor = UIColor.white
        self.deathlogScreen.strokeColor = UIColor.black
        self.deathlogScreen.name = "death log"
        self.deathlogScreen.isHidden = true
        self.addChild(deathlogScreen)
        
        self.deathMessage.text = "You Failed"
        self.deathMessage.position = CGPoint(x: 0, y: self.size.height/(4 * 3))
        self.deathMessage.fontSize = 70
        self.deathMessage.fontColor = UIColor.black
        deathlogScreen.addChild(deathMessage)
        
        self.deathScoreReport.text = "You Scored"
        self.deathScoreReport.position = CGPoint(x: 0, y: -self.size.height/(4 * 4))
        self.deathScoreReport.fontSize = 40
        self.deathScoreReport.fontColor = UIColor.black
        deathlogScreen.addChild(deathScoreReport)
        
        self.restartButton.text = "Tap to Restart"
        self.restartButton.position = CGPoint(x: 0, y: -self.size.height/(4 * 3/2))
        self.restartButton.fontSize = 40
        self.restartButton.fontColor = UIColor.black
        deathlogScreen.addChild(restartButton)

        //MARK:   ---Sound Effects Setup---
        //Punch sound
        //Sword Sound
        let punchSound = URL(fileURLWithPath: Bundle.main.path(forResource: "punch", ofType: "wav")!)
        punchSoundEffect = try! AVAudioPlayer.init(contentsOf: punchSound)
        punchSoundEffect.prepareToPlay()
        punchSoundEffect.numberOfLoops = 0
        
        let gunSound = URL(fileURLWithPath: Bundle.main.path(forResource: "GunShot", ofType: "mp3")!)
        gunSoundEffect = try! AVAudioPlayer.init(contentsOf: gunSound)
        gunSoundEffect.prepareToPlay()
        gunSoundEffect.numberOfLoops = 0

        //Screen Boarder
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

    }

    //When the screen is tapped    //MARK: Report tapped coordinates
    override func touchesBegan(_ touches:Set<UITouch>, with event:UIEvent?) {
        /* Called when a touch begins */

        for touch in touches {
            if reportTaps {
                print("Tap Location" + String(describing: touch.location(in: self)))

            }
        }
    }

    //When screen tapped is lifted    //MARK: Moves charc, fireSwords and enable restart
    override func touchesEnded(_ touches:Set<UITouch>, with event:UIEvent?) {
        buttonTapped = false

        for touch in touches {

            for i in self.nodes(at: touch.location(in: self)) {
                if i.name == "Fire!" && !death {
                    buttonTapped = true
                    fireSwords(charcLocation: self.charc.position)
                }
                
                //MARK: Restart
                if death && birdArray.count == 0 && i.name == "death log"{
                    reinitGame()
                }
                
            }
            moveCharc(UserInput: touch)
        }
    }

    //MARK: Move the charc
    func moveCharc(UserInput touch :UITouch) {
        if(!death){
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
    }

    //MARK: Fire Swords
    func fireSwords(charcLocation charcPos:CGPoint) {

        let theSwordLook = SKTexture(imageNamed: "the_other_sword.png")
        let theBullet = SKTexture(imageNamed: "Bullet.png")
        var aSword = SKSpriteNode()
        
        if (childFriendly){
            aSword = SKSpriteNode(texture: theSwordLook)
            aSword.position = CGPoint(x: charcPos.x + 40, y: charcPos.y - 25)
            aSword.xScale = 0.5
            aSword.yScale = 0.5
        }
        else if (!childFriendly){
            aSword = SKSpriteNode(texture: theBullet)
            aSword.position = CGPoint(x: charcPos.x + 40, y: charcPos.y - 8)
            gunSoundEffect.currentTime = 0.005
            gunSoundEffect.play()
        }
        
        aSword.zPosition = 3
        swordsArray.append(aSword)

        let moveSword = SKAction.repeat(SKAction.moveBy(x: swordSpeed, y: 0, duration: swordUpdateTime), count: Int(self.size.width / swordSpeed))
        let swordSequence = SKAction.sequence([moveSword, SKAction.removeFromParent()])
        aSword.run(swordSequence, completion: { self.removeFirstSwordFromArray() })
        self.addChild(aSword)

    }

    //Updates before each frame renders    //MARK: Add birds and detect collision
    override func update(_ currentTime:TimeInterval) {
        //The array for  birds that were hit
        var birdRemovalArray = [Int?](repeating: nil, count: 0)

        //MARK: Collision Check
        if (birdArray.count >= 1 && swordsArray.count >= 1) {
            for i in 0 ... birdArray.count - 1 {
                for j in 0 ... swordsArray.count - 1 {
                    let selectedBird = birdArray[i]
                    let selectedSword = swordsArray[j]

                    if ((!(selectedBird == nil) && !(selectedSword == nil)) && (!(swordsArray.count == 0) && !(birdArray.count == 0))) {
                        if ((selectedBird?.intersects(selectedSword!))! == true) {

                            if (childFriendly) {punchSoundEffect.play()}

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

        //MARK: Remove birds from array
        if !(birdRemovalArray.count == 0) {
            for k in 0 ... birdRemovalArray.count - 1 {
                //print("Inside for loop.")
                if !(birdRemovalArray[birdRemovalArray.count - k - 1] == nil) {
                    KillSelectedBirdFromArray(selectedBirdIndex: birdRemovalArray[birdRemovalArray.count - k - 1]!)
                }
            }
        }

        //MARK: Send Birds
        let NewBird = Int(arc4random() % 100)
        if (NewBird <= birdControl && !death) {

            let theFirstBirdSkin = SKTexture(imageNamed: "downflappybird.png")
            let theSecondBirdSkin = SKTexture(imageNamed: "upflappybird.png")
            let aBird = SKSpriteNode(texture: theFirstBirdSkin)
            
            aBird.xScale = 0.125
            aBird.yScale = 0.125

            let birdFlapWings = SKAction.repeatForever(SKAction.animate(with: [theFirstBirdSkin, theSecondBirdSkin], timePerFrame: 0.1))
            
            let additionalBirdSpeed = CGFloat(arc4random() % UInt32(self.additionalSpeedLimit))
            let moveTheBird = SKAction.repeat(SKAction.moveBy(x: -1 * (CGFloat(birdSpeed) + additionalBirdSpeed), y: 0, duration: 0.2), count: (Int(self.size.width + aBird.size.width * 1)) / birdSpeed)
            let birdSequence = SKAction.sequence([moveTheBird, SKAction.removeFromParent()])

            let randomBirdPosY = CGFloat((arc4random_uniform(UInt32(self.size.height * 5 / 8))) + UInt32(self.size.height * 1 / 4))
            aBird.position = CGPoint(x: self.size.width + (aBird.size.width) * 2, y: randomBirdPosY)
            aBird.zPosition = 4
            birdArray.append(aBird)
            print("Bird array length:" + String(birdArray.count))

            aBird.run(birdFlapWings)
            aBird.run(birdSequence, completion: { self.removeFirstBirdFromArray() })

            self.addChild(aBird)
        }
    }

    //MARK: Remove first bird
    func removeFirstBirdFromArray() -> Void {
        birdArray.remove(at: 0)
        playerDidDie()
    }

    //MARK: Remove first sword
    func removeFirstSwordFromArray() -> Void {
        swordsArray.remove(at: 0)
    }

    //MARK: Kill the bird that was hit
    func KillSelectedBirdFromArray(selectedBirdIndex Index:Int) -> Void {
        print("Bird array length before remove:" + String(birdArray.count))
        print("Selected bird index:" + String(Index))
        let birdFall = SKAction.repeat(SKAction.moveBy(x: 0, y: CGFloat(-3 * birdSpeed), duration: 0.1), count: (Int((1.2 * (birdArray[Index]?.position.y)!)) / (2 * birdSpeed)))
        let birdDeathSequence = SKAction.sequence([birdFall, SKAction.removeFromParent()])

        self.birdArray[Index]?.run(birdDeathSequence)
        self.birdArray.remove(at: Index)

        print("Bird array length after remove:" + String(birdArray.count))
        
        //MARK: Add Score
        if(!death){
            self.gameScore = self.gameScore + 1
            self.displayScore.text = String(self.gameScore)
        }
        
        //MARK: Difficulty
        if(gameScore % 10 == 0 && birdControl <= 100){
            birdControl += 5
        }

        
    }

    //MARK: Death Function
    func playerDidDie() -> Void {
        
        self.deathScoreReport.text = String(gameScore) + " Bird Kills"
        
        if(!death){
            self.deathlogScreen.isHidden = false
            self.deathlogScreen.xScale = 0.1
            self.deathlogScreen.yScale = 0.1
            self.deathlogScreen.run(SKAction.scale(by: 10, duration: 3))
        }
            
        self.death = true
        
    }
    
    //MARK: Reinitialize
    func reinitGame() -> Void {
        death = false
        buttonTapped = true
        gameScore = 0
        displayScore.text = "0"
        birdControl = 1
        charc.position = CGPoint(x: self.frame.size.width / 10, y: self.frame.size.height / 2)
        self.deathlogScreen.run(SKAction.scale(by: 0, duration: 0.5))
    }
}
