//
//  MirrorBall.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/03/27.
//

import Foundation
import MetalKit

class Sphere: Node {
    var mesh: MTKMesh!
    var pipelineState: MTLRenderPipelineState!
    var timer: Float = 0
    
    init(name: String) {
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        
        let mdlMesh = MDLMesh(sphereWithExtent: [1, 1, 1],
                              segments: [16, 8],
                              inwardNormals: false,
                              geometryType: .triangles,
                              allocator: allocator)

        mesh = try! MTKMesh(mesh: mdlMesh, device: Renderer.device)
        let vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)  // MTLVertexDescriptor.defaultVertexDescriptor()

        let renderDescriptor = MTLRenderPipelineDescriptor()
        renderDescriptor.vertexDescriptor = vertexDescriptor
//        renderDescriptor.sampleCount = mtkView.sampleCount
        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderDescriptor.vertexFunction = Renderer.library.makeFunction(name: "vertex_mirrorball")
        renderDescriptor.fragmentFunction = Renderer.library.makeFunction(name: "fragment_mirrorball")
        renderDescriptor.depthAttachmentPixelFormat = .depth32Float
//        renderDescriptor.stencilAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        pipelineState = try! Renderer.device.makeRenderPipelineState(descriptor: renderDescriptor)
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

extension Sphere: Renderable {
    func render(commandEncoder: MTLRenderCommandEncoder,
                uniforms vertex: Uniforms,
                fragmentUniforms fragment: FragmentUniforms){
        var uniforms = vertex
        var fragmentUniforms = fragment
        
        commandEncoder.setRenderPipelineState(pipelineState)
        
        uniforms.modelMatrix = worldMatrix
        
        timer += 0.05
        var currentTime = timer
        
        commandEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 2)

        commandEncoder.setVertexBytes(&uniforms,
                                      length: MemoryLayout<Uniforms>.stride,
                                      index: 21)
        
        commandEncoder.setFragmentBytes(&fragmentUniforms,
                                       length: MemoryLayout<FragmentUniforms>.stride,
                                       index: 22)
        
        commandEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        commandEncoder.drawIndexedPrimitives(type: mesh.submeshes[0].primitiveType,
                                            indexCount: mesh.submeshes[0].indexCount,
                                            indexType: mesh.submeshes[0].indexType,
                                            indexBuffer: mesh.submeshes[0].indexBuffer.buffer,
                                            indexBufferOffset: mesh.submeshes[0].indexBuffer.offset)
        
    }
}

class MirrorBall : Scene {

    override func setupScene() {
        camera.target = [0, 0.45, -0.3]
        camera.distance = 4
        camera.rotation = [-0.4, -0.8, 0]

        let mirrorball = Sphere(name: "mirrorball")
        add(node: mirrorball)
    }
}
