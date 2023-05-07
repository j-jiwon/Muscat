//
//  MirrorBall.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/05/07.
//

import Foundation
import MetalKit


class Skybox: Node {
    var mesh: MTKMesh!
    var pipelineState: MTLRenderPipelineState!
    var timer: Float = 0
    var environmentTexture: MTLTexture!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    
    init(name: String) {
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        
        let cubeTextureOptions: [MTKTextureLoader.Option : Any] = [
            .textureUsage : MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode : MTLStorageMode.private.rawValue,
            .generateMipmaps : true,
            .cubeLayout : MTKTextureLoader.CubeLayout.vertical
        ]
        let environmentTextureURL = Bundle.main.url(forResource: "environment", withExtension: "png")!
        environmentTexture = try? MTKTextureLoader(device: Renderer.device).newTexture(URL: environmentTextureURL, options: cubeTextureOptions)
        
        let environmentPipelineDescriptor = MTLRenderPipelineDescriptor()
        environmentPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        environmentPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        environmentPipelineDescriptor.vertexFunction = Renderer.library.makeFunction(name: "vertex_env")!
        environmentPipelineDescriptor.fragmentFunction = Renderer.library.makeFunction(name: "fragment_env")!
        
        pipelineState = try! Renderer.device.makeRenderPipelineState(descriptor: environmentPipelineDescriptor)
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = Renderer.device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        
        samplerState = Renderer.device.makeSamplerState(descriptor: samplerDescriptor)
    }
}

extension Skybox: Renderable {
    func render(commandEncoder: MTLRenderCommandEncoder,
                uniforms vertex: Uniforms,
                fragmentUniforms fragment: FragmentUniforms){
        var uniforms = vertex
        var fragmentUniforms = fragment
        
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setFrontFacing(.counterClockwise)
        commandEncoder.setCullMode(.back)
        
        commandEncoder.setRenderPipelineState(pipelineState)
        
        uniforms.modelMatrix = worldMatrix
        
        timer += 0.05
        var currentTime = timer
        var clipToViewDirectionTransform = (vertex.projectionMatrix * vertex.viewMatrix).inverse
        
        commandEncoder.setFragmentBytes(&clipToViewDirectionTransform, length: MemoryLayout<float4x4>.size, index: 0)
        
        commandEncoder.setFragmentTexture(environmentTexture, index: 0)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }
}

class MirrorBall : Scene {

    override func setupScene() {
        camera.target = [0, 0.45, -0.3]
        camera.distance = 4
        camera.rotation = [-0.4, -0.8, 0]

        let skybox = Skybox(name: "skybox")
        add(node: skybox)
        
        let sphere = Model(name: "sphere")
        add(node: sphere)
    }
}
