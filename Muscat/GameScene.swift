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
        
        let trees = Instance(name: "treefir", instanceCount: 4)
        let train = Model(name: "train")
        
        add(node: train)
        add(node: trees)
        
        trees.transforms[0].position.x = train.worldBoundingBox().x
        trees.transforms[1].position.z = -train.worldBoundingBox().z
        trees.transforms[2].position.x = train.worldBoundingBox().x + train.worldBoundingBox().width
        trees.transforms[3].position.z = -train.worldBoundingBox().z - train.worldBoundingBox().height
    }
}
