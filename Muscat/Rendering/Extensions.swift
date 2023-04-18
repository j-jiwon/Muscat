//
//  Extensions.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/14.
//

import Foundation
import MetalKit


struct Rect {
    var x: Float = 0
    var z: Float = 0
    var width: Float = 0
    var height: Float = 0
    
    private var cgRect: CGRect {
        return CGRect(x: CGFloat(x), y: CGFloat(z), width: CGFloat(width), height: CGFloat(height))
    }
    
    func intersects(rect: Rect) -> Bool {
        return self.cgRect.intersects(rect.cgRect)
    }
}

extension MTLVertexDescriptor {
    static func defaultVertexDescriptor() -> MTLVertexDescriptor{
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride * 2
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        let stride = MemoryLayout<SIMD3<Float>>.stride * 2 + MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.layouts[0].stride = stride
        return vertexDescriptor
    }
}


extension MDLVertexDescriptor {
    var vertexAttributes: [MDLVertexAttribute] {
        return attributes as! [MDLVertexAttribute]
    }

    var bufferLayouts: [MDLVertexBufferLayout] {
        return layouts as! [MDLVertexBufferLayout]
    }
    
    static func defaultVertexDescriptor () -> MDLVertexDescriptor {
        let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(MTLVertexDescriptor.defaultVertexDescriptor())
        let attributePosition = vertexDescriptor.attributes[0] as! MDLVertexAttribute
        attributePosition.name = MDLVertexAttributePosition
        
        let attributeNormal = vertexDescriptor.attributes[1] as! MDLVertexAttribute
        attributeNormal.name = MDLVertexAttributeNormal
        
        let attributeUV = vertexDescriptor.attributes[2] as! MDLVertexAttribute
        attributeUV.name = MDLVertexAttributeTextureCoordinate
         
        return vertexDescriptor
    }
}

#if os(macOS)
extension Scene {
  @objc func keyDown(key: Int, isARepeat: Bool) -> Bool {
    // override this
    return false
  }
  
  @objc func keyUp(key: Int) -> Bool {
    // override this
    return false
  }
  
  @objc func click(location: SIMD2<Float>) {
    // override
  }
}

//extension ViewController {
//  func addKeyboardMonitoring() {
//    NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
//      if self.keyDown(with: $0) {
//        return nil
//      } else {
//        return $0
//      }
//    }
//    NSEvent.addLocalMonitorForEvents(matching: .keyUp) {
//      if self.keyUp(with: $0) {
//        return nil
//      } else {
//        return $0
//      }
//    }
//  }
  
//  func keyDown(with event: NSEvent)-> Bool {
//    guard let window = self.view.window,
//      let scene = scene,
//      NSApplication.shared.keyWindow === window
//      else {
//        return false
//    }
//    return scene.keyDown(key: Int(event.keyCode), isARepeat: event.isARepeat)
//  }
//
//  func keyUp(with event: NSEvent) -> Bool {
//    guard let window = self.view.window,
//      let scene = scene,
//      NSApplication.shared.keyWindow === window else {
//        return false
//    }
//    return scene.keyUp(key: Int(event.keyCode))
//  }
//
//  @objc func handleClick(gesture: NSClickGestureRecognizer) {
//    let location = gesture.location(in: metalView)
//    scene?.click(location: SIMD2<Float>(Float(location.x), Float(location.y)))
//  }
//}
#endif
