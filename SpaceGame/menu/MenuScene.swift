//
//  MenuScene.swift
//  SpaceGame
//
//  Created by d.genkov on 3/20/19.
//  Copyright © 2019 d.genkov. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {

	var starField: SKEmitterNode!
	var newGameButtonNode: SKSpriteNode!
	var difficultyButtonNode: SKSpriteNode!
	var difficultyLabelNode: SKLabelNode!

	override func didMove(to view: SKView) {
		starField = self.childNode(withName: "starFieldEmitter") as? SKEmitterNode
		starField.advanceSimulationTime(10)

		newGameButtonNode = self.childNode(withName: "newGameButtonName") as? SKSpriteNode
		difficultyButtonNode = self.childNode(withName: "difficultyButtonName") as? SKSpriteNode

		difficultyLabelNode = self.childNode(withName: "difficultyLabelName") as? SKLabelNode

		let userDefaults = UserDefaults.standard
		if userDefaults.bool(forKey: "hard") {
			difficultyLabelNode.text = "HARD"
		} else {
			difficultyLabelNode.text = "EASY"
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first
		if let location = touch?.location(in: self) {
			let nodesArray = self.nodes(at: location)
			if nodesArray.first?.name == "newGameButtonName" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5)
				let gameScene = GameScene(fileNamed: "GameScene")!
				self.view?.presentScene(gameScene, transition: transition)
			} else if nodesArray.first?.name == "difficultyButtonName" {
				changeDifficulty()
			}
		}
	}

	func changeDifficulty() {
		let userDefaults = UserDefaults.standard

		if difficultyLabelNode.text == "EASY" {
			difficultyLabelNode.text = "HARD"
			userDefaults.set(true, forKey: "hard")
		} else {
			difficultyLabelNode.text = "EASY"
			userDefaults.set(false, forKey: "hard")
		}
		userDefaults.synchronize()
	}

}
