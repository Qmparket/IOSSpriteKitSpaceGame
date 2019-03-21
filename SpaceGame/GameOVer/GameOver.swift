//
//  GameOver.swift
//  SpaceGame
//
//  Created by d.genkov on 3/20/19.
//  Copyright © 2019 d.genkov. All rights reserved.
//

import SpriteKit

class GameOver: SKScene {

	var difficultyButton: SKSpriteNode!
	var difficultyLabel: SKLabelNode!
	var playAgainButton: SKSpriteNode!
	var starEmitter: SKEmitterNode!

	var hard: Bool!

	override func didMove(to view: SKView) {
		starEmitter = SKEmitterNode(fileNamed: "Starfield")
		starEmitter.position = CGPoint(x: frame.width / 2, y: 1200)
		starEmitter.advanceSimulationTime(10)
		self.addChild(starEmitter)

		starEmitter.zPosition = -1
		difficultyLabel = self.childNode(withName: "difficultyLabel") as? SKLabelNode
		difficultyButton = self.childNode(withName: "difficultyButton") as? SKSpriteNode
		hard = UserDefaults.standard.bool(forKey: "hard")

		if hard {
			difficultyLabel.text = "HARD"
		} else {
			difficultyLabel.text = "EASY"
		}

	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first
		if let location = touch?.location(in: self) {
			let nodesArray = self.nodes(at: location)
			if nodesArray.first?.name == "difficultyButton" {
				changeDifficulty()
			} else if nodesArray.first?.name == "playAgainButton" {
				let transition = SKTransition.flipVertical(withDuration: 0.5)
				let gameScene = GameScene(fileNamed: "GameScene")!
				self.view?.presentScene(gameScene, transition: transition)
			}
		}
	}

	func changeDifficulty() {
		if hard {
			hard = false
			UserDefaults.standard.set(hard, forKey: "hard")
			difficultyLabel.text = "EASY"
		} else {
			hard = true
			UserDefaults.standard.set(hard, forKey: "hard")
			difficultyLabel.text = "HARD"
		}
	}

}
