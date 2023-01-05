//
//  Model.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/15.
//

import Foundation
import MetalKit

class Model: Node {
    
    var mdlMeshes: [MDLMesh]
    var mtkMeshes: [MTKMesh]
    
    var transform = Transform()
    
    
    init(name: String) {
        let assetUrl = Bundle.main.url(forResource: name, withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        
        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor()
        let asset = MDLAsset(url:assetUrl,
                             vertexDescriptor: vertexDescriptor,
                             bufferAllocator: allocator)
        
        let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)
        self.mdlMeshes = mdlMeshes
        self.mtkMeshes = mtkMeshes
        
        super.init()
        self.name = name
    }
}

extension Model: Renderable {
    func render(commandEncoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms){
        var uniforms = vertex
        
        uniforms.modelMatrix = worldMatrix
        commandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 21)
        
        for mtkMesh in mtkMeshes {
            for vertexBuffer in mtkMesh.vertexBuffers {
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                
                var color = 0
                
                for submesh in mtkMesh.submeshes {
                    
                    commandEncoder.setVertexBytes(&color, length: MemoryLayout<Int>.stride, index: 11)
                    
                    commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                         indexCount: submesh.indexCount,
                                                         indexType: submesh.indexType,
                                                         indexBuffer: submesh.indexBuffer.buffer,
                                                         indexBufferOffset: submesh.indexBuffer.offset)
                    
                    color += 1
                }
            }
        }
    }
}
