//
//  Model.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/15.
//

import Foundation
import MetalKit

class Model {
    
    var mdlMeshes: [MDLMesh]
    var mtkMeshes: [MTKMesh]
    
    init(name: String) {
        let assetUrl = Bundle.main.url(forResource: name, withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        
        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor()
        let asset = MDLAsset(url:assetUrl,
                             vertexDescriptor: vertexDescriptor,
                             bufferAllocator: allocator)
        
        let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)
        self.mdlMeshes = mdlMeshes
        self.mtkMeshes = mtkMeshes
    }
}
