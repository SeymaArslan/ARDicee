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
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
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
    
    //MARK: - Dice Rendering Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane,
                                                  alignment: .horizontal) {
                let results = sceneView.session.raycast(query)
                //                  if !results.isEmpty {
                //                    print("Touched the plane: \(results)")
                //                  } else {
                //                    print("Touched somewhere else")
                //                  }
                if let raycastResult = results.first {
                    addDice(atLocation: raycastResult)
                }
            }
            
        }
    }
    
    func addDice(atLocation location: ARRaycastResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceColladacopy.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)

        }
    }
    
    func roll(dice: SCNNode) {
        // animation
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5))
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

//        createPlane(withPlaneAnchor: planeAnchor)
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    //MARK: - Plane Rendering Methods
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        let gridMetal = SCNMaterial()
        gridMetal.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMetal]
        planeNode.geometry = plane
        return planeNode
    }

}
