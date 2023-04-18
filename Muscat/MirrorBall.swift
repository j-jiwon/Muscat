////
////  MirrorBall.swift
////  Muscat
////
////  Created by Jiwon Jung on 2023/03/27.
////
//
//import Foundation
//import MetalKit
//import Metal
//import simd
//
//class Ball: Node {
//    init(mesh: MTKMesh)
//    {
//        super.init()
//        self.mesh = mesh
//    }
//}
//
//class Sphere: Node {
//    var pipelineState: MTLRenderPipelineState!
//    var timer: Float = 0
//
//    var ballNode: Node!
//
//    // scene
//    private var vertexDescriptor: MTLVertexDescriptor!
//    private var clipToViewDirectionTransform = matrix_identity_float4x4
//    private var environmentTexture: MTLTexture!
//    private var environmentRenderPipelineState: MTLRenderPipelineState!
//
////    private var depthStencilState: MTLDepthStencilState!
//    private var samplerState: MTLSamplerState!
//
//    private var textureLoader: MTKTextureLoader!
//    private let textureOption: [MTKTextureLoader.Option: Any] = [
//        .textureUsage: MTLTextureUsage.shaderRead.rawValue,
//        .textureStorageMode: MTLStorageMode.private.rawValue,
//        .origin: MTKTextureLoader.Origin.bottomLeft.rawValue
//    ]
//    private var allocator: MTKMeshBufferAllocator!
//
//    private var constantBuffer: MTLBuffer!
//    private var currentConstantBufferOffset = 0
//    private var frameConstantsOffset = 0
//    private var lightConstantsOffset = 0
//
//
//    init(name: String) {
//
//        super.init()
//        self.makeScene()
//        self.makePipelines()
//    }
//
//    func makeScene()
//    {
//        let cubeTextureOptions: [MTKTextureLoader.Option : Any] = [
//            .textureUsage: MTLTextureUsage.shaderRead.rawValue,
//            .textureStorageMode: MTLStorageMode.private.rawValue,
//            .generateMipmaps: true,
//            .cubeLayout: MTKTextureLoader.CubeLayout.vertical
//        ]
//        let enviromentTextureURL = Bundle.main.url(forResource: "environment", withExtension: "png")!
//        textureLoader = MTKTextureLoader(device: Renderer.device)
//        environmentTexture = try! textureLoader.newTexture(URL: enviromentTextureURL, options:cubeTextureOptions)
//
//        allocator = MTKMeshBufferAllocator(device: Renderer.device)
//        let mdlSphere = MDLMesh(sphereWithExtent: [1, 1, 1],
//                              segments: [16, 8],
//                              inwardNormals: false,
//                              geometryType: .triangles,
//                              allocator: allocator)
//        self.mesh = try! MTKMesh(mesh: mdlSphere, device: Renderer.device)
//        ballNode = Ball(mesh: self.mesh)
//        add(childNode: ballNode)
//    }
//
//    func makePipelines()
//    {
//
//        let renderDescriptor = MTLRenderPipelineDescriptor()
//        vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
//        renderDescriptor.vertexDescriptor = vertexDescriptor
//        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        renderDescriptor.depthAttachmentPixelFormat = .depth32Float
////        renderDescriptor.colorAttachments[0].isBlendingEnabled = true
//        renderDescriptor.vertexFunction = Renderer.library.makeFunction(name: "vertex_mirrorball")
//        renderDescriptor.fragmentFunction = Renderer.library.makeFunction(name: "fragment_mirrorball")
////        renderDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
////        renderDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
////        renderDescriptor.colorAttachments[0].rgbBlendOperation = .add
////        renderDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
////        renderDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
////        renderDescriptor.colorAttachments[0].alphaBlendOperation = .add
//
//        pipelineState = try! Renderer.device.makeRenderPipelineState(descriptor: renderDescriptor)
//
//        let environmentDescriptor = MTLRenderPipelineDescriptor()
//        environmentDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        environmentDescriptor.depthAttachmentPixelFormat = .depth32Float
//        environmentDescriptor.vertexFunction = Renderer.library.makeFunction(name: "vertex_env")!
//        environmentDescriptor.fragmentFunction = Renderer.library.makeFunction(name: "fragment_env")!
//
//        environmentRenderPipelineState = try! Renderer.device.makeRenderPipelineState(descriptor: environmentDescriptor)
//
//        let samplerDescriptor = MTLSamplerDescriptor()
//        samplerDescriptor.normalizedCoordinates = true
//        samplerDescriptor.magFilter = .linear
//        samplerDescriptor.minFilter = .linear
//        samplerDescriptor.mipFilter = .linear
//        samplerDescriptor.sAddressMode = .repeat
//        samplerDescriptor.tAddressMode = .repeat
//        samplerState = Renderer.device.makeSamplerState(descriptor: samplerDescriptor)!
//    }
//}
//
//extension Sphere: Renderable {
//    func render(commandEncoder: MTLRenderCommandEncoder,
//                uniforms vertex: Uniforms,
//                fragmentUniforms fragment: FragmentUniforms){
//        var uniforms = vertex
//        var fragmentUniforms = fragment
//
//        drawEnvironment(commandEncoder)
//
//        commandEncoder.setRenderPipelineState(pipelineState)
//        uniforms.modelMatrix = worldMatrix
//
//        timer += 0.05
//        var currentTime = timer
//
//        commandEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 2)
//
//        commandEncoder.setVertexBytes(&uniforms,
//                                      length: MemoryLayout<Uniforms>.stride,
//                                      index: 21)
//
//        commandEncoder.setFragmentBytes(&fragmentUniforms,
//                                       length: MemoryLayout<FragmentUniforms>.stride,
//                                       index: 22)
//
//        commandEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
//
//        commandEncoder.drawIndexedPrimitives(type: mesh.submeshes[0].primitiveType,
//                                            indexCount: mesh.submeshes[0].indexCount,
//                                            indexType: mesh.submeshes[0].indexType,
//                                            indexBuffer: mesh.submeshes[0].indexBuffer.buffer,
//                                            indexBufferOffset: mesh.submeshes[0].indexBuffer.offset)
//    }
//
//    func drawEnvironment(_ commandEncoder: MTLRenderCommandEncoder)
//    {
//        commandEncoder.setRenderPipelineState(environmentRenderPipelineState)
//        commandEncoder.setFragmentBytes(&clipToViewDirectionTransform, length: MemoryLayout<float4x4>.size, index: 0)
//        commandEncoder.setFragmentTexture(environmentTexture, index: 0)
//        commandEncoder.setFragmentSamplerState(samplerState, index: 0)
//        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
//    }
//}
//
//
//class MirrorBall : Scene {
//    private var time: Float = 0
//
//    var mirrorball: Sphere!
//    override init(sceneSize: CGSize) {
//        super.init(sceneSize: sceneSize)
//    }
//
//    override func setupScene() {
//        camera.target = [0, 0.45, -0.3]
//        camera.distance = 4
//        camera.rotation = [-0.4, -0.8, 0]
//
//        mirrorball = try! Sphere(name: "mirror")
//        add(node: mirrorball)
//    }
//
//    override func updateScene(deltaTime: Float) {
//        let t = deltaTime
//        time += t
//
////        mirrorball.rotation = SIMD3<Float>(1, 0 ,0)
//
//    }
//}
