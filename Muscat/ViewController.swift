//
//  ViewController.swift
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/05.
//

import Cocoa
import MetalKit
class ViewController: NSViewController {
    @IBOutlet var metalView: MTKView!
    var renderer: Renderer?
    var scene: Scene?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        renderer = Renderer(view: metalView)
        scene = MirrorBall(sceneSize: metalView.bounds.size)
        scene?.sceneDelegate = self
        renderer?.scene = scene
        
        metalView.device = Renderer.device
        metalView.delegate = renderer
        metalView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(pan)
        
        let click = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        view.addGestureRecognizer(click)
        
        addKeyboardMonitoring()
    }
    
    override func scrollWheel(with event: NSEvent) {
        scene?.camera.zoom(delta: Float(event.deltaY))
    }

    @objc func handlePan(gesture: NSPanGestureRecognizer) {
      let translation = gesture.translation(in: gesture.view)
      let delta = SIMD2<Float>(Float(translation.x),
                               Float(translation.y))
      
      scene?.camera.rotate(delta: delta)
      gesture.setTranslation(.zero, in: gesture.view)
    }
}

extension ViewController: SceneDelegate {
    func transition(to scene: Scene) {
        scene.sceneDelegate = self
        self.scene = scene
        renderer?.scene = scene
    }
}
