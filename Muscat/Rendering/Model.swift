//
//  Model.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/15.
//

import Foundation
import MetalKit

class Model: Node {
    let meshes: [Mesh]
    var fileTye: String
    
    init(name: String, fileType: String = "obj") {
        self.fileTye = fileType
        let assetUrl = Bundle.main.url(forResource: name, withExtension: fileType)!
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        
        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor()
        let asset = MDLAsset(url:assetUrl,
                             vertexDescriptor: vertexDescriptor,
                             bufferAllocator: allocator)
        
        asset.loadTextures()
        
        let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)
        
        meshes = zip(mdlMeshes, mtkMeshes).map {
            Mesh(mdlMesh: $0.0, mtkMesh: $0.1)
        }
        
        super.init()
        self.name = name
        self.boundingBox = mdlMeshes[0].boundingBox
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
        let mtkSubmesh = submesh.mtkSubmesh
        
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: mtkSubmesh.indexCount,
                                             indexType: mtkSubmesh.indexType,
                                             indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                             indexBufferOffset: mtkSubmesh.indexBuffer.offset)
    }
}

extension Model: Renderable {
    func render(commandEncoder: MTLRenderCommandEncoder,
                uniforms vertex: Uniforms,
                fragmentUniforms fragment: FragmentUniforms){
        var uniforms = vertex
        var fragmentUniforms = fragment
        
        uniforms.modelMatrix = worldMatrix
        commandEncoder.setVertexBytes(&uniforms,
                                      length: MemoryLayout<Uniforms>.stride,
                                      index: 21)
        
        commandEncoder.setFragmentBytes(&fragmentUniforms,
                                       length: MemoryLayout<FragmentUniforms>.stride,
                                       index: 22)
        
        for mesh in meshes {
            for vertexBuffer in mesh.mtkMesh.vertexBuffers {
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                
                for submesh in mesh.submeshes {
                    commandEncoder.setRenderPipelineState(submesh.pipelineState)
                    var material = submesh.material
                    commandEncoder.setFragmentBytes(&material,
                                                    length: MemoryLayout<Material>.stride,
                                                    index: 11)
                    commandEncoder.setFragmentTexture(submesh.textures.baseColor, index: 0)

                    render(commandEncoder: commandEncoder, submesh: submesh)
                }
            }
        }
    }
}
