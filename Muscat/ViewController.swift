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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        renderer = Renderer(view: metalView)
        metalView.device = Renderer.device
        metalView.delegate = renderer
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(pan)
    }
    
    override func scrollWheel(with event: NSEvent) {
        renderer?.camera.zoom(delta: Float(event.deltaY))
    }

    @objc func handlePan(gesture: NSPanGestureRecognizer) {
      let translation = gesture.translation(in: gesture.view)
      let delta = float2(Float(translation.x),
                         Float(translation.y))
      
      renderer?.camera.rotate(delta: delta)
      gesture.setTranslation(.zero, in: gesture.view)
    }
}

