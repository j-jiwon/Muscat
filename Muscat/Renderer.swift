//
//  Renderer.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/05.
//

import Foundation
import MetalKit

struct Vertex
{
    let position: float3
    let color: float3
}

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    
    let train: Model
    let tree: Model
    
    var timer: Float = 0
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        pipelineState = Renderer.createPipelineState()
        
        train = Model(name: "train")
        train.transform.position = [0.4, 0, 0]
        train.transform.scale = 0.5
        
        tree = Model(name:"treefir")
        tree.transform.position = [-1.0, 0, 0.3]
        tree.transform.scale = 0.5
        super.init()
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        // pipeline state properties
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    // resize, rotate io device
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    // gpu interaction
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.setRenderPipelineState(pipelineState)
        
        let projectionMatrix = float4x4(projectionFov: radians(fromDegrees: 65), near: 0.1, far: 100, aspect: Float(view.bounds.width / view.bounds.height))
        
        var viewTransform = Transform()
        viewTransform.position.y = 1.0
        viewTransform.position.z = -2.0
        
        
        var viewMatrix = projectionMatrix * viewTransform.matrix.inverse
        commandEncoder.setVertexBytes(&viewMatrix, length: MemoryLayout<float4x4>.stride, index: 22)
        
        let models = [train, tree]
        for model in models {
            
            var modelMatrix = model.transform.matrix
            commandEncoder.setVertexBytes(&modelMatrix, length: MemoryLayout<float4x4>.stride, index: 21)
            
            for mtkMesh in model.mtkMeshes {
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


        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
