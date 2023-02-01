//
//  GameOver.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/02/02.
//

import Foundation

class GameOver: Scene {
    
    var messageModel: Model?
    
    var win = false {
        didSet {
            if win {
                messageModel = Model(name: "youwin")
            } else {
                messageModel = Model(name: "youlose")
            }
            add(node: messageModel!)
        }
    }
    
    override func click(location: SIMD2<Float>) {
        let scene = RayBreak(sceneSize:  sceneSize)
        sceneDelegate?.transition(to: scene)
    }
    
    override func setupScene() {
        camera.distance = 15
        camera.fov = radians(fromDegrees: 100)
    }
    
    override func updateScene(deltaTime: Float) {
        messageModel?.rotation.y += .pi / 4 * deltaTime
    }
}
