////
////  Wave.swift
////  Muscat
////
////  Created by Jiwon Jung on 2023/02/16.
////
//
//import Foundation
//import MetalKit
//
//
//class Plane: Node {
//    var mesh: MTKMesh!
//    var pipelineState: MTLRenderPipelineState!
//    var timer: Float = 0
//
//    init(name: String) {
//        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
//
//        let mdlMesh = MDLMesh(planeWithExtent: float3(3, 0, 3), segments: vector_uint2(100, 100),
//                              geometryType: .triangles, allocator: allocator)
//
//        mesh = try! MTKMesh(mesh: mdlMesh, device: Renderer.device)
//        let vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)  // MTLVertexDescriptor.defaultVertexDescriptor()
//
//        let renderDescriptor = MTLRenderPipelineDescriptor()
//        renderDescriptor.vertexDescriptor = vertexDescriptor
////        renderDescriptor.sampleCount = mtkView.sampleCount
//        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        renderDescriptor.vertexFunction = Renderer.library.makeFunction(name: "vertex_wave")
//        renderDescriptor.fragmentFunction = Renderer.library.makeFunction(name: "fragment_wave")
//        renderDescriptor.depthAttachmentPixelFormat = .depth32Float
////        renderDescriptor.stencilAttachmentPixelFormat = mtkView.depthStencilPixelFormat
//        pipelineState = try! Renderer.device.makeRenderPipelineState(descriptor: renderDescriptor)
//    }
//
//}
//
//extension Plane: Renderable {
//    func render(commandEncoder: MTLRenderCommandEncoder,
//                uniforms vertex: Uniforms,
//                fragmentUniforms fragment: FragmentUniforms){
//        var uniforms = vertex
//        var fragmentUniforms = fragment
//
//        commandEncoder.setRenderPipelineState(pipelineState)
//
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
//
//    }
//}
//
//class Wave : Scene {
//
//    override func setupScene() {
//        camera.target = [0, 0.45, -0.3]
//        camera.distance = 4
//        camera.rotation = [-0.4, -0.8, 0]
//
//        let plane = Plane(name: "plane")
//        add(node: plane)
//    }
//}
