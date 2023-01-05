//
//  Renderable.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/01/06.
//

import Foundation
import MetalKit

protocol Renderable {
    var name: String { get }
    
    func render(commandEncoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms)
}
