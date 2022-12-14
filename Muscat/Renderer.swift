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
    let depthStencilState: MTLDepthStencilState
    
    weak var scene: Scene?
    
    let camera = ArcballCamera()
    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    
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
        depthStencilState = Renderer.createDepthState()
        
        camera.target = [0, 0.8, 0]
        camera.distance = 3
        
        view.depthStencilPixelFormat = .depth32Float
        
        super.init()
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    static func createDepthState()->MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
    }
}

extension Renderer: MTKViewDelegate {
    // resize, rotate io device
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width / view.bounds.height)
    }
    
    // gpu interaction
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
        let scene = scene else {
            return
        }
                
        var viewTransform = Transform()
        viewTransform.position.y = 1.0
        viewTransform.position.z = -2.0
        
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setDepthStencilState(depthStencilState)
        
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        
        fragmentUniforms.cameraPosition = camera.transform.position
        commandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride,
                                        index: 22)
        
        for renderable in scene.renderables {
            // using DebugGroup methods, will be able to see which model is being rendered in the GPU debugger.
            commandEncoder.pushDebugGroup(renderable.name)
            renderable.render(commandEncoder: commandEncoder, uniforms: uniforms)
            commandEncoder.popDebugGroup()
        }

        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
