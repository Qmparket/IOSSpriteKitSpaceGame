//
//  GameScene.swift
//  SpaceGame
//
//  Created by d.genkov on 3/15/19.
//  Copyright © 2019 d.genkov. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

	var starfield: SKEmitterNode!
	var player: SKSpriteNode!

	var viewWidth: CGFloat!
	var viewHeight: CGFloat!

	var scoreLabel: SKLabelNode!
	var score: Int = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

	var gameTimer: Timer!

	var possibleAliens = ["alien", "alien2", "alien3"]

	let alienCategory: UInt32 = 0x1 << 1
	let photonTorpedoCategory: UInt32 = 0x1 << 0

	let motionManager = CMMotionManager()
	var xAcceleration: CGFloat = 0

	var livesArray: [SKSpriteNode]!
    
    override func didMove(to view: SKView) {

		viewHeight = view.frame.size.height
		viewWidth = view.frame.size.width

		if (viewHeight <= frame.size.height) {
			viewHeight = frame.size.height / viewHeight * viewHeight
		}

		if (viewWidth <= frame.size.width) {
			viewWidth = frame.size.width / viewWidth * viewWidth
		}
		addLives()

		starfield = SKEmitterNode(fileNamed: "Starfield")
		starfield.position = CGPoint(x: 0, y: 1400)
		starfield.advanceSimulationTime(10)
		self.addChild(starfield)

		starfield.zPosition = -1

		player = SKSpriteNode(imageNamed: "shuttle")

		player.position = CGPoint(x: 0, y: -viewHeight / 2 + player.size.height + 10)
		// player.position = CGPoint(x: 0, y: 0)

		print(viewHeight)
		print(viewWidth)
		self.addChild(player)

		self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		self.physicsWorld.contactDelegate = self

		scoreLabel = SKLabelNode(text: "Score: 0")
		scoreLabel.position = CGPoint(x: -viewWidth / 2 + scoreLabel.frame.size.width + 10 , y: viewHeight / 2 - scoreLabel.frame.size.height - 30)
		scoreLabel.fontName = "AmericanTypewriter-Bold"
		scoreLabel.fontSize = 36
		scoreLabel.fontColor = UIColor.white
		score = 0
		self.addChild(scoreLabel)

		var timeInterval = 0.9

		if UserDefaults.standard.bool(forKey: "hard") {
			timeInterval = 0.5
		}
		gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)

		motionManager.accelerometerUpdateInterval = 0.2
		motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
			if let accelerometerData = data {
				let acceleration = accelerometerData.acceleration
				self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
			}
		}

    }

	func addLives() {
		livesArray = [SKSpriteNode]()
		for live in 1...3 {
			let liveNode = SKSpriteNode(imageNamed: "shuttle")
			liveNode.position = CGPoint(x: self.frame.size.width / 2 - CGFloat(4 - live) * liveNode.size.width - 5, y:  viewHeight / 2 - liveNode.size.height - 10)
			self.addChild(liveNode)
			livesArray.append(liveNode)
		}
	}

	@objc func addAlien() {
		possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
		let alien = SKSpriteNode(imageNamed: possibleAliens[0])

		let randomAlienPosition = GKRandomDistribution(lowestValue: Int(-viewWidth / 2), highestValue: Int(viewWidth / 2))
		let position = CGFloat(randomAlienPosition.nextInt())

		alien.position = CGPoint(x: position, y: viewHeight / 2)
		alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
		alien.physicsBody?.isDynamic = true

		alien.physicsBody?.categoryBitMask = alienCategory
		alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
		alien.physicsBody?.collisionBitMask = 0

		self.addChild(alien)
		let animationDuration: TimeInterval = 7

		var actionArray = [SKAction]()
		actionArray.append(SKAction.move(to: CGPoint(x: position, y: -viewHeight / 2 - alien.size.height), duration: animationDuration))
		actionArray.append(SKAction.run {
			self.run(SKAction.playSoundFileNamed("liveLost.mp3", waitForCompletion: false))

			if self.livesArray.count > 0 {
				let liveNode = self.livesArray.first
				liveNode?.removeFromParent()
				self.livesArray.removeFirst()

				if(self.livesArray.count == 0) {
					let transition = SKTransition.flipVertical(withDuration: 0.5)
					let gameOver = GameOver(fileNamed: "GameOver")!
					self.view?.presentScene(gameOver, transition: transition)
				}
			}
		})
		actionArray.append(SKAction.removeFromParent())
		alien.run(SKAction.sequence(actionArray))
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		fireTorpedo()
	}

	func fireTorpedo() {
		self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))

		let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
		torpedoNode.position = player.position
		torpedoNode.position.y += 5

		torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
		torpedoNode.physicsBody?.isDynamic = true
		torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
		torpedoNode.physicsBody?.contactTestBitMask = alienCategory
		torpedoNode.physicsBody?.collisionBitMask = 0

		torpedoNode.physicsBody?.usesPreciseCollisionDetection = true

		self.addChild(torpedoNode)

		let animationDuration: TimeInterval = 0.3

		var actionArray = [SKAction]()
		actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: viewHeight / 2 + torpedoNode.size.height), duration: animationDuration))
		actionArray.append(SKAction.removeFromParent())
		torpedoNode.run(SKAction.sequence(actionArray))

	}

	func didBegin(_ contact: SKPhysicsContact) {
		var firstBody: SKPhysicsBody
		var secondBody: SKPhysicsBody

		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		if ((firstBody.categoryBitMask & photonTorpedoCategory) != 0
		&& (secondBody.categoryBitMask & alienCategory) != 0) {
			torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
		}
	}

	func torpedoDidCollideWithAlien (torpedoNode: SKSpriteNode, alienNode: SKSpriteNode) {
		guard let explosion = SKEmitterNode(fileNamed: "Explosion") else { return }
		explosion.position = alienNode.position
		self.addChild(explosion)

		self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))

		torpedoNode.removeFromParent()
		alienNode.removeFromParent()

		self.run(SKAction.wait(forDuration: 2)) {
			explosion.removeFromParent()
		}

		score += 5
	}

	override func didSimulatePhysics() {
		player.position.x += xAcceleration * 50
		if (player.position.x < -viewWidth / 2 - 10) {
			player.position = CGPoint(x: viewWidth / 2, y: player.position.y)
		} else if player.position.x > viewWidth / 2 + 10 {
			player.position = CGPoint(x: -viewWidth / 2, y: player.position.y)
		}
	}
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
