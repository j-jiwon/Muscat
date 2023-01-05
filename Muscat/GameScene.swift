//
//  GameScene.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/01/06.
//

import Foundation

class GameScene: Scene {
    let train = Model(name: "train")
    
    override func setupScene() {
        add(node: train)
        
        let tree = Model(name: "treefir")
        add(node: tree)
        tree.position.x = -2.0
    }
}
