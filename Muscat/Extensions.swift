//
//  Extensions.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/14.
//

import Foundation
import MetalKit

extension MTLVertexDescriptor {
    static func defaultVertexDescriptor() -> MTLVertexDescriptor{
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        return vertexDescriptor
    }
}


extension MDLVertexDescriptor {
    static func defaultVertexDescriptor () -> MDLVertexDescriptor {
        let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultVertexDescriptor())
        let attributePosition = vertexDescriptor.attributes[0] as! MDLVertexAttribute
        attributePosition.name = MDLVertexAttributePosition
        
        return vertexDescriptor
    }
}
