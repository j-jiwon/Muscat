//
//  Node.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/01/06.
//

import Foundation
import ModelIO
import MetalKit

class Node {
    var name = "Untitled"
    var mesh: MTKMesh?
    
    var position = SIMD3<Float>(repeating: 0)
    var rotation = SIMD3<Float>(repeating: 0)
    var scale: Float = 1.0
    
    var matrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotationMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return scaleMatrix * rotationMatrix * translateMatrix
    }
    
    var parent: Node?
    var children: [Node] = []
    
    var worldMatrix: float4x4 {
        if let parent = parent {
            return parent.worldMatrix * matrix
        }
        return matrix
    }
    
    var boundingBox = MDLAxisAlignedBoundingBox() // AABB
    
    final func add(childNode: Node){
        children.append(childNode)
        childNode.parent = self
    }
    
    final func remove(childNode: Node){
        for child in childNode.children {
            child.parent = self
            children.append(child)
        }
        childNode.children = []
        guard let index = (children.firstIndex {
            $0 === childNode
        }) else { return }
        children.remove(at: index)
    }
    
    func worldBoundingBox(matrix: float4x4? = nil) -> Rect {
        var worldMatrix = self.worldMatrix
        // include all the matrices from the parent node.
        if let matrix = matrix {
            worldMatrix = worldMatrix * matrix
        }
        var bottomLeft = SIMD4<Float>(boundingBox.minBounds.x, 0, boundingBox.minBounds.z, 1)
        bottomLeft = worldMatrix * bottomLeft
        
        var topRight = SIMD4<Float>(boundingBox.maxBounds.x, 0, boundingBox.maxBounds.z, 1)
        topRight = worldMatrix * topRight
        
        return Rect(x: bottomLeft.x,
                    z: bottomLeft.z,
                    width:topRight.x - bottomLeft.x,
                    height:topRight.z - bottomLeft.z)
    }
}
