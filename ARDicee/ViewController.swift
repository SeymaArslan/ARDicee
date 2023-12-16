//
//  ViewController.swift
//  ARDicee
//
//  Created by Seyma on 11.12.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
////        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let sphere = SCNSphere(radius: 0.2)
//        let material = SCNMaterial()
////        material.diffuse.contents = UIColor.red  for cube
//        material.diffuse.contents = UIImage(named: "art.scnassets/2k_moon.jpg")
//        sphere.materials = [material]
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0, z: -0.5)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
//        let diceScene = SCNScene(named: "art.scnassets/diceColladacopy.scn")!
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//            sceneView.scene.rootNode.addChildNode(diceNode)
//        }
  
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane,
            alignment: .horizontal) {
                  let results = sceneView.session.raycast(query)
                  if !results.isEmpty {
                    print("Touched the plane: \(results)")
                  } else {
                    print("Touched somewhere else")
                  }
                }

        }
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMetal = SCNMaterial()
            gridMetal.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMetal]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
    

}
