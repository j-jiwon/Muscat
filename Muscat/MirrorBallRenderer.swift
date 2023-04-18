//
//  MirrorBallRenderer.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/04/05.
//

import Foundation
import Metal
import MetalKit
import simd

let MaxConstantsSize = 1024 * 1024
let MinBufferAlignment = 256

struct InstanceConstants {
    var modelMatrix: float4x4
}

struct FrameConstants {
    var projectionMatrix: float4x4
    var viewMatrix: float4x4
    var inverseViewDirectionMatrix: float3x3
}

class MirrorballRenderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let view: MTKView

    var pointOfView = Node()
    var donutNode: Node!
    var nodes = [Node]()

    private var nodeConstantOffsets = [Int]()

    private let mdlVertexDescriptor = MDLVertexDescriptor()
    private var vertexDescriptor: MTLVertexDescriptor!

    private var clipToViewDirectionTransform = matrix_identity_float4x4
    private var environmentTexture: MTLTexture!
    private var environmentRenderPipelineState: MTLRenderPipelineState!

    private var renderPipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var samplerState: MTLSamplerState!

    private var bufferAllocator: MTKMeshBufferAllocator!
    private var textureLoader: MTKTextureLoader!
    private let textureOptions: [MTKTextureLoader.Option : Any] = [
        .textureUsage : MTLTextureUsage.shaderRead.rawValue,
        .textureStorageMode : MTLStorageMode.private.rawValue,
        .origin : MTKTextureLoader.Origin.bottomLeft.rawValue
    ]

    private var constantBuffer: MTLBuffer!
    private var currentConstantBufferOffset = 0
    private var frameConstantsOffset = 0

    private var frameIndex = 0
    private var time: TimeInterval = 0

    init(device: MTLDevice, view: MTKView) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.view = view

        super.init()

        view.device = device
        view.delegate = self
        view.colorPixelFormat = .bgra8Unorm_srgb
        view.depthStencilPixelFormat = .depth32Float
        view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        view.sampleCount = 1

        bufferAllocator = MTKMeshBufferAllocator(device: device)
        textureLoader = MTKTextureLoader(device: device)
        constantBuffer = device.makeBuffer(length: MaxConstantsSize, options: .storageModeShared)

        makeScene()
        makePipelines()
    }

    func makeScene() {
        // NOTE : extension의 default 함수로 생성 시 모양 이상함. 간격의 문젠가..
        mdlVertexDescriptor.vertexAttributes[0].name = MDLVertexAttributePosition
        mdlVertexDescriptor.vertexAttributes[0].format = .float3
        mdlVertexDescriptor.vertexAttributes[0].offset = 0
        mdlVertexDescriptor.vertexAttributes[0].bufferIndex = 0
        mdlVertexDescriptor.vertexAttributes[1].name = MDLVertexAttributeNormal
        mdlVertexDescriptor.vertexAttributes[1].format = .float3
        mdlVertexDescriptor.vertexAttributes[1].offset = 12
        mdlVertexDescriptor.vertexAttributes[1].bufferIndex = 0
        mdlVertexDescriptor.vertexAttributes[2].name = MDLVertexAttributeTextureCoordinate
        mdlVertexDescriptor.vertexAttributes[2].format = .float2
        mdlVertexDescriptor.vertexAttributes[2].offset = 24
        mdlVertexDescriptor.vertexAttributes[2].bufferIndex = 0
        mdlVertexDescriptor.bufferLayouts[0].stride = 32

        vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlVertexDescriptor)

        let cubeTextureOptions: [MTKTextureLoader.Option : Any] = [
            .textureUsage : MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode : MTLStorageMode.private.rawValue,
            .generateMipmaps : true,
            .cubeLayout : MTKTextureLoader.CubeLayout.vertical
        ]
        let environmentTextureURL = Bundle.main.url(forResource: "environment", withExtension: "png")!
        environmentTexture = try? textureLoader.newTexture(URL: environmentTextureURL, options: cubeTextureOptions)

        let mdlSphere = MDLMesh(sphereWithExtent: [1, 1, 1],
                              segments: [32, 32],
                              inwardNormals: false,
                              geometryType: .triangles,
                              allocator: bufferAllocator)
        let mtkTorus = try! MTKMesh(mesh: mdlSphere, device: device)
        donutNode = Node()
        donutNode.mesh = mtkTorus
        nodes.append(donutNode)
    }

    func makePipelines() {
        let library = device.makeDefaultLibrary()!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.rasterSampleCount = view.sampleCount

        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat

        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_mirrorball")!
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_mirrorball")!

        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

        renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let environmentPipelineDescriptor = MTLRenderPipelineDescriptor()
        environmentPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        environmentPipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        environmentPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_env")!
        environmentPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_env")!
        environmentRenderPipelineState = try! device.makeRenderPipelineState(descriptor: environmentPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!
    }

    func allocateConstantStorage(size: Int, alignment: Int) -> Int {
        let effectiveAlignment = lcm(alignment, MinBufferAlignment)
        var allocationOffset = align(currentConstantBufferOffset, upTo: effectiveAlignment)
        if (allocationOffset + size >= MaxConstantsSize) {
            allocationOffset = 0
        }
        currentConstantBufferOffset = allocationOffset + size
        return allocationOffset
    }

    func updateFrameConstants() {
        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        let projectionMatrix = float4x4(projectionFov: .pi/3, near: 0.01, far: 100, aspect: aspectRatio)
        
//        let cameraMatrix = pointOfView.worldMatrix
        var cameraMatrix = pointOfView.worldMatrix
        cameraMatrix.columns.3 = SIMD4<Float>(0, 0, 4, 1)
        let viewMatrix = cameraMatrix.inverse

        var viewDirectionMatrix = viewMatrix
        viewDirectionMatrix.columns.3 = SIMD4<Float>(0, 0, 0, 1)
        clipToViewDirectionTransform = (projectionMatrix * viewDirectionMatrix).inverse

        var constants = FrameConstants(projectionMatrix: projectionMatrix,
                                       viewMatrix: viewMatrix,
                                       inverseViewDirectionMatrix: viewDirectionMatrix.inverse.upperLeft)

        let layout = MemoryLayout<FrameConstants>.self
        frameConstantsOffset = allocateConstantStorage(size: layout.size, alignment: layout.stride)
        let constantsPointer = constantBuffer.contents().advanced(by: frameConstantsOffset)
        constantsPointer.copyMemory(from: &constants, byteCount: layout.size)

    }
    
}

extension MirrorballRenderer: MTKViewDelegate{

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {

        let timestep = 1.0 / Double(view.preferredFramesPerSecond)
        time += timestep

        updateFrameConstants()

        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        drawMainPass(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)

        commandBuffer.present(view.currentDrawable!)

        commandBuffer.commit()

    }
    
    func drawEnvironment(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(environmentRenderPipelineState)

        renderCommandEncoder.setFragmentBytes(&clipToViewDirectionTransform,
                                              length: MemoryLayout<float4x4>.size,
                                              index: 0)
        renderCommandEncoder.setFragmentTexture(environmentTexture, index: 0)
        renderCommandEncoder.setFragmentSamplerState(samplerState, index: 0)

        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }

    
    func drawMainPass(renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setFrontFacing(.counterClockwise)
        renderCommandEncoder.setCullMode(.back)

        drawEnvironment(renderCommandEncoder)

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)

        renderCommandEncoder.setVertexBuffer(constantBuffer, offset: frameConstantsOffset, index: 3)
        renderCommandEncoder.setFragmentBuffer(constantBuffer, offset: frameConstantsOffset, index: 3)

        let mesh = donutNode.mesh!
        let layout = MemoryLayout<InstanceConstants>.self
        let offset = allocateConstantStorage(size: layout.stride, alignment: layout.stride)

        let instanceConstants = constantBuffer.contents().advanced(by: offset)
        var instance = InstanceConstants(modelMatrix: donutNode.worldMatrix)
        instanceConstants.copyMemory(from: &instance, byteCount: layout.size)
        renderCommandEncoder.setVertexBuffer(constantBuffer, offset: offset, index: 2)

        for meshBuffer in mesh.vertexBuffers {
            renderCommandEncoder.setVertexBuffer(meshBuffer.buffer,
                                                 offset: meshBuffer.offset,
                                                 index: 0)
        }

        renderCommandEncoder.setFragmentTexture(environmentTexture, index: 0)
        renderCommandEncoder.setFragmentSamplerState(samplerState, index: 0)

        for submesh in mesh.submeshes {
            let indexBuffer = submesh.indexBuffer
            renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                       indexCount: submesh.indexCount,
                                                       indexType: submesh.indexType,
                                                       indexBuffer: indexBuffer.buffer,
                                                       indexBufferOffset: indexBuffer.offset)
        }
        
        renderCommandEncoder.endEncoding()
    }
}
