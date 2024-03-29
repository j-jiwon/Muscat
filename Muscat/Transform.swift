//
//  Transform.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/20.
//

import Foundation
import simd

struct Transform
{
    var position = SIMD3<Float>(repeating: 0)
    var rotation = SIMD3<Float>(repeating: 0)
    var scale: Float = 1
    
    var matrix : float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotationMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        
        return translateMatrix * rotationMatrix * scaleMatrix
    }
}
