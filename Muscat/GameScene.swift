//
//  GameScene.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/01/06.
//

import Foundation

class GameScene: Scene {
    let trains = Instance(name: "train", instanceCount: 100)
    let trees = Instance(name: "treefir", instanceCount: 100)

    override func setupScene() {
        camera.target = [0, 0.8, 0]
        camera.distance = 8
        camera.rotation = [-0.4, -0.4, 0]
    
        add(node: trees)
        add(node: trains)
        
        for i in 0..<100 {
            trains.transforms[i].position.x = Float.random(in: -5..<5)
            trains.transforms[i].position.z = Float.random(in: 0..<10)
            trains.transforms[i].rotation.y = Float.random(in: 0..<radians(fromDegrees: 359))
            
            trees.transforms[i].position.x = Float(i) - 50
            trees.transforms[i].position.z = 2
        }
    }
}
