//
//  RayBreak.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/02/01.
//

import Foundation

class RayBreak: Scene {
    enum Constants {
        static let columns = 4
        static let rows = 6
        static let paddleSpeed: Float = 0.2
        static let ballSpeed: Float = 10
    }
    
    var ballVelocity = float3(Constants.ballSpeed, 0, Constants.ballSpeed)
    
    
    let paddle = Model(name: "paddle")
    let ball = Model(name: "ball")
    let border = Model(name: "border")
    let bricks = Instance(name: "brick", instanceCount: Constants.rows * Constants.columns)
    
    var gameArea: (width: Float, height: Float) = (0, 0)
    
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
                
                var position = float3(0)
                position.x = margin + hGap * fcol + brickWidth * fcol + halfBricksWidth
                position.x -= halfGameWidth
                position.z = vGap * frow + brickWidth * frow
                let transform = Transform(position: position, rotation: float3(0), scale: 1)
                bricks.transforms[row * Constants.columns + column] = transform
            }
        }
                    
    }
    
    override func setupScene() {
        camera.rotation = [-0.78, 0, 0]
        camera.distance = 13.5
        camera.target.y = -2
        
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
        }
        if abs(ball.position.z) > gameArea.height / 2 {
            ballVelocity.z = -ballVelocity.z
        }
        
        if ball.worldBoundingBox().intersects(rect: paddle.worldBoundingBox()){
            ballVelocity.z = -ballVelocity.z
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
            print("Game over")
        }
    }
    
    override func updateScene(deltaTime: Float) {
        ball.position += ballVelocity * deltaTime
        checkBricks()
        bounceBall()
    }
}
