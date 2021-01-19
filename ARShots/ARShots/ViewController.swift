//
//  ViewController.swift
//  ARShots
//
//  Created by Kanashima Hatsumi on 10/1/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Hit testing
    var hoopAdded = false
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        if !hoopAdded{
            let touchLocation = sender.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(touchLocation, types:
               [.existingPlane])
            if let result = hitTestResult.first {
                print("Ray intersected a discovered plane")
                addHoop(result: result)
                hoopAdded = true
            }
        } else{
            createBasketball()
        }
    }
    
    func createBasketball(){
        guard let currentFrame = sceneView.session.currentFrame else{return}
        let ball = SCNNode(geometry: SCNSphere(radius:0.05))
        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        
        // SCNMatrix -> 4x4 matrix defining rotation and position of object
        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        ball.transform = cameraTransform
        
        let physicsBody = SCNPhysicsBody(type:.dynamic,shape:SCNPhysicsShape(node:ball, options:[SCNPhysicsShape.Option.collisionMargin:0.01]))
        
        let power = Float(10.0)
        //m31 -> x value, m32 -> y-value, m33 -> z-value
        // negative sign because we need to flip direction of force
        
        let force = SCNVector3(-cameraTransform.m31*power, -cameraTransform.m32*power,-cameraTransform.m33*power)
        ball.physicsBody?.applyForce(force, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(ball)
    }
    
    func addHoop(result: ARHitTestResult) {
        // Retrieve the scene file and locate the "Hoop" node
        let hoopScene = SCNScene(named: "art.scnassets/hoop.scn")
        
        // create Node variable from SCN file
        guard let hoopNode = hoopScene?.rootNode.childNode(withName:
          "Hoop", recursively: false) else {
            return
        }
    
        // Place the node in the correct position
        // worldTransform.columns.3 gives the xyz-position of the detected plane
        let planePosition = result.worldTransform.columns.3
        // set Hoop node position to be that of detected plane
        hoopNode.position = SCNVector3(planePosition.x, planePosition.y, planePosition.z)
        
        hoopNode.physicsBody = SCNPhysicsBody(type: .static, shape:SCNPhysicsShape(node:hoopNode,options:[SCNPhysicsShape.Option.type:SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        //Add the node to the scene
        sceneView.scene.rootNode.addChildNode(hoopNode)
    }
    

//    func createBasketball() {
//        guard let currentFrame = sceneView.session.currentFrame else {return}
//        let ball = SCNNode(geometry:SCNSphere(radius: 0.25))
//        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
//        
//        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
//        ball.transform = cameraTransform
//
//        sceneView.scene.rootNode.addChildNode(ball)
//    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
