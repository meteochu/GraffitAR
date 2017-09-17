//
//  ARCanvasViewController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Firebase

class ARCanvasViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let vertBrush = VertBrush()
    
    var isDrawing: Bool = false
    
    var frameIdx = 0
    
    var splitLine = false
    
    var lineRadius : Float = 0.001
    
    var metalLayer: CAMetalLayer! = nil
    
    var hasSetupPipeline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        metalLayer = self.sceneView.layer as! CAMetalLayer
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        // setup the brush
//        vertBrush.setupPipeline(device: sceneView.device!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func didSelectSaveButton(_ sender: UIButton) {
        // save thing...
        print("Saving AR map...")
        let graffitiObj = vertBrush.getGraffitiPoints()
        let alertController = UIAlertController(title: "Save Graffiti", message: "Please enter a name for your artwork.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Artwork Name..."
        }
        alertController.addTextField { textField in
            textField.placeholder = "Enter Artwork Detail..."
        }
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let nameField = alertController.textFields![0], detailField = alertController.textFields![1]
            let name = nameField.text ?? "Artwork"
            let detail = detailField.text ?? ""
            
            DataController.shared.uploadGraffiti(graffitiObj, image: self.sceneView.snapshot(), named: name, detail: detail) { error in
                if let error = error {
                    let errorController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    errorController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    alertController.present(errorController, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didSelectDrawButton(_ sender: UIButton) {
        self.isDrawing = !self.isDrawing
        if ( self.isDrawing ) {
            self.splitLine = true
        }
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if self.isDrawing {
            let pointer = getPointerPosition()
            if pointer.valid {
                
                if vertBrush.points.isEmpty || (vertBrush.points.last! - pointer.pos).length() > 0.001 {
                    var radius : Float = 0.001
                    if splitLine || vertBrush.points.count < 2 {
                        lineRadius = 0.001
                    } else {
                        let i = vertBrush.points.count-1
                        let p1 = vertBrush.points[i]
                        let p2 = vertBrush.points[i-1]
                        radius = 0.001 + min(0.015, 0.005 * pow( ( p2-p1 ).length() / 0.005, 2))
                    }
                    
                    lineRadius = lineRadius - (lineRadius - radius)*0.075
                    vertBrush.addPoint(pointer.pos, radius: lineRadius, splitLine:splitLine)
                    
                    if splitLine {
                        splitLine = false
                    }
                }
            }
        }
        
        if frameIdx % 100 == 0 {
            print(vertBrush.points.count, " points")
        }
        
        frameIdx = frameIdx + 1
        vertBrush.updateBuffers()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if !hasSetupPipeline {
            // pixelFormat is different if called at viewWillAppear
            hasSetupPipeline = true
            vertBrush.setupPipeline(device: sceneView.device!, pixelFormat: self.metalLayer.pixelFormat)
        }
        
        if let commandQueue = self.sceneView?.commandQueue {
            if let encoder = self.sceneView.currentRenderCommandEncoder {
                let projMat = float4x4(self.sceneView.pointOfView!.camera!.projectionTransform)
                let modelViewMat = float4x4(self.sceneView.pointOfView!.worldTransform).inverse
                vertBrush.render(commandQueue, encoder, parentModelViewMatrix: modelViewMat, projectionMatrix: projMat)     
            }
        }
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: stuff
    
    func getPointerPosition() -> (pos : SCNVector3, valid: Bool, camPos : SCNVector3 ) {
        
        guard let pointOfView = sceneView.pointOfView else { return (SCNVector3Zero, false, SCNVector3Zero) }
        guard let currentFrame = sceneView.session.currentFrame else { return (SCNVector3Zero, false, SCNVector3Zero) }
        
        let mat = SCNMatrix4.init(currentFrame.camera.transform)
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let currentPosition = pointOfView.position + (dir * 0.12)
        
        return (currentPosition, true, pointOfView.position)
        
    }

}
