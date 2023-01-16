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
    let depthStencilState: MTLDepthStencilState
    
    weak var scene: Scene?
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        view.depthStencilPixelFormat = .depth32Float
        depthStencilState = Renderer.createDepthState()

        super.init()
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
        scene?.sceneSizeWillChange(to: size)
    }
    
    // gpu interaction
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
        let scene = scene else {
            return
        }
        
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.setDepthStencilState(depthStencilState)
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        scene.update(deltaTime: deltaTime)
        
        for renderable in scene.renderables {
            // using DebugGroup methods, will be able to see which model is being rendered in the GPU debugger.
            commandEncoder.pushDebugGroup(renderable.name)
            renderable.render(commandEncoder: commandEncoder,
                              uniforms: scene.uniforms,
                              fragmentUniforms: scene.fragmentUniforms)
            commandEncoder.popDebugGroup()
        }

        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
