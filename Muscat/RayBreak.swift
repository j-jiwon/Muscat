//
//  RayBreak.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/02/01.
//

import Foundation
import AVFoundation

class RayBreak: Scene {
    enum Constants {
        static let columns = 4
        static let rows = 6
        static let paddleSpeed: Float = 0.2
        static let ballSpeed: Float = 10
    }
    
    enum Sounds {
        static let win = "win.wav"
        static let lose = "lose.wav"
        static let bounce = "bounce.wav"
    }
    
    var ballVelocity = SIMD3<Float>(Constants.ballSpeed, 0, Constants.ballSpeed)
    
    var lives = 3
    
    let paddle = Model(name: "paddle")
    let ball = Model(name: "ball")
    let border = Model(name: "border")
    let bricks = Instance(name: "brick", instanceCount: Constants.rows * Constants.columns)
    
    var gameArea: (width: Float, height: Float) = (0, 0)
    
    var keyLeftDown = false
    var keyRightDown = false
    
    var bounced = false
    
    func setupSounds() {
        soundController.load(soundNames: [Sounds.bounce, Sounds.lose, Sounds.win])
        soundController.playBackgroundMusic("bulletstorm_bg_v1")
    }
    
    override func keyDown(key: Int, isARepeat: Bool) -> Bool {
        switch key {
        case 123:  // left arrow
            keyLeftDown = true
        case 124:  // right arrow
            keyRightDown = true
        default:
            return false
        }
        return true
    }
    
    override func keyUp(key: Int) -> Bool {
        switch key {
        case 123:  // left arrow
            keyLeftDown = false
        case 124:  // right arrow
            keyRightDown = false
        default:
            break
        }
        return true
    }
    
    func setupBricks() {
        let margin = gameArea.width * 0.1
        let brickWidth = bricks.worldBoundingBox().width
        
        let halfGameWidth = gameArea.width / 2
        let halfGameHeight = gameArea.height / 2
        let halfBricksWidth = brickWidth / 2
        let cols = Float(Constants.columns)
        let rows = Float(Constants.rows)
        
        let hGap = (gameArea.width - brickWidth * cols - margin * 2) / (cols - 1)
        let vGap = (halfGameHeight - brickWidth * rows - margin + halfBricksWidth) / (rows - 1)
        for row in 0..<Constants.rows {
            for column in 0..<Constants.columns {
                let frow = Float(row)
                let fcol = Float(column)
                
                var position = SIMD3<Float>(repeating: 0)
                position.x = margin + hGap * fcol + brickWidth * fcol + halfBricksWidth
                position.x -= halfGameWidth
                position.z = vGap * frow + brickWidth * frow
                let transform = Transform(position: position, rotation: SIMD3<Float>(repeating: 0), scale: 1)
                bricks.transforms[row * Constants.columns + column] = transform
            }
        }
                    
    }
    
    override func setupScene() {
        camera.rotation = [-0.78, 0, 0]
        camera.distance = 13.5
        camera.target.y = -2
        
        setupSounds()
        
        gameArea.width = border.worldBoundingBox().width - 1
        gameArea.height = border.worldBoundingBox().height - 1
        
        add(node: paddle)
        add(node: ball)
        add(node: border)
        add(node: bricks)
        
        paddle.position.z = -border.worldBoundingBox().height / 2.0 + 2
        ball.position.z = paddle.position.z + 1
        
        setupBricks()
    }
    
    func bounceBall() {
        if abs(ball.position.x) > gameArea.width / 2 {
            ballVelocity.x = -ballVelocity.x
            bounced = true
        }
        if abs(ball.position.z) > gameArea.height / 2 {
            if ball.position.z < 0 {
                lives -= 1
                if lives < 0 {
                    print("Game Over")
                } else {
                    print("Lives: ", lives)
                }
            }
            ballVelocity.z = -ballVelocity.z
            bounced = true
        }
        
        if ball.worldBoundingBox().intersects(rect: paddle.worldBoundingBox()){
            ballVelocity.z = -ballVelocity.z
            bounced = true
        }
    }
    
    func checkBricks() {
        var brickToDestroyIndex: Int?
        for (i, transform) in bricks.transforms.enumerated() {
            let modelMatrix = bricks.matrix * transform.matrix
            let brickRect = bricks.worldBoundingBox(matrix: modelMatrix)
            if ball.worldBoundingBox().intersects(rect: brickRect) {
                brickToDestroyIndex = i
                break
            }
        }
        if let index = brickToDestroyIndex {
            bricks.transforms.remove(at: index)
            bricks.instanceCount -= 1
            ballVelocity.z = -ballVelocity.z
        }
        
        if bricks.instanceCount <= 0{
            remove(node: bricks)
            print("WIN")
        }
    }
    
    override func updateScene(deltaTime: Float) {
        bounced = false
        
        ball.position += ballVelocity * deltaTime
        checkBricks()
        bounceBall()
        
        let oldPaddlePosition = paddle.position.x
        
        if keyLeftDown {
            paddle.position.x -= Constants.paddleSpeed
        }
        if keyRightDown {
            paddle.position.x += Constants.paddleSpeed
        }
        let paddleWidth = paddle.worldBoundingBox().width
        let halfBorderWith = border.worldBoundingBox().width / 2
        if abs(paddle.position.x) + (paddleWidth / 2) > halfBorderWith {
            paddle.position.x = oldPaddlePosition
        }
        
        let transforms: [Transform] = bricks.transforms.map {
            var transform = $0
            transform.rotation.y += Float.pi / 4 * deltaTime
            return transform
        }
        bricks.transforms = transforms
        
        if bounced {
            soundController.playEffect(name: Sounds.bounce)
        }
    }
}
