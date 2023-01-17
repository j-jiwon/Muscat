//
//  GameScene.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/01/06.
//

import Foundation

class GameScene: Scene {

    override func setupScene() {
        camera.target = [0, 0.8, 0]
        camera.distance = 8
        camera.rotation = [-0.4, -0.4, 0]
    }
}
