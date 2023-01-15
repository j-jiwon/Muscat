//
//  Scene.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/01/06.
//

import Foundation

class Scene {
    var rootNode = Node()
    var renderables: [Renderable] = []
    var sceneSize: CGSize
    
    let camera = ArcballCamera()
    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        sceneSizeWillChange(to: sceneSize)
        setupScene()
    }
    
    func updateScene(deltaTime: Float){
        
    }
    
    final func update(deltaTime: Float) {
      updateScene(deltaTime: deltaTime)
      uniforms.projectionMatrix = camera.projectionMatrix
      uniforms.viewMatrix = camera.viewMatrix
      fragmentUniforms.cameraPosition = camera.position
    }
    
    final func add(node: Node, parent: Node? = nil, render: Bool = true){
        if let parent = parent {
            parent.add(childNode: node)
        } else {
            rootNode.add(childNode: node)
        }
        if render, let renderable = node as? Renderable {
            renderables.append(renderable)
        }
    }
    
    final func remove(node: Node) {
      if let parent = node.parent {
        parent.remove(childNode: node)
      } else {
        for child in node.children {
          child.parent = nil
        }
        node.children = []
      }
      
      if node is Renderable,
        let index = renderables.firstIndex(where: { $0 as? Node === node }) {
        renderables.remove(at: index)
      }
    }
    
    func setupScene() {
        // override this to add objects to the scene
    }
    
    func sceneSizeWillChange(to size: CGSize){
        camera.aspect = Float(size.width / size.height)
        sceneSize = size
    }
}
