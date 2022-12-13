//
//  Renderer.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/05.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    
    let positionArray: [float4] = [
        float4(-0.5, 0.0, 0, 1),
        float4(0.0, 0.0, 0, 1),
        float4(-0.5, 0.5, 0, 1),
        float4(0.0, 0.5, 0, 1),
    ]

    let colorArray: [float3] = [
        float3(1, 0, 0),
        float3(0, 1, 0),
        float3(0, 0, 1),
        float3(1, 0, 0),
    ]
    
    let indexArray: [uint16] = [
        0, 1, 2,
        2, 1, 3
    ]
    
    let positionBuffer: MTLBuffer
    let colorBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
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
        
        let positionLength = MemoryLayout<float4>.stride * positionArray.count
        positionBuffer = device.makeBuffer(bytes: positionArray, length: positionLength, options: [])!
        let colorLength = MemoryLayout<float3>.stride * colorArray.count
        colorBuffer = device.makeBuffer(bytes: colorArray, length: colorLength, options:[])!
        let indexLength = MemoryLayout<uint16>.stride * indexArray.count
        indexBuffer = device.makeBuffer(bytes: indexArray, length: indexLength, options: [])!
        
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
              let descriptor = view.currentRenderPassDescriptor,
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        commandEncoder.setRenderPipelineState(pipelineState)
        
        commandEncoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indexArray.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
