//
//  ViewController.swift
//  Space Portal
//
//  Created by Francisco Gonzalez on 5/16/19.
//  Copyright © 2019 Francisco Gonzalez. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            self.addPortal(hitTestResult: hitTestResult.first!)
        }
        
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        
        let portalScene = SCNScene(named: "Portal.scn")
        let portalNode = portalScene!.rootNode.childNode(withName: "Portal", recursively: false)!
        let transform = hitTestResult.worldTransform
        let planeXPosition = transform.columns.3.x
        let planeYPosition = transform.columns.3.y
        let planeZPosition = transform.columns.3.z
        portalNode.position = SCNVector3(planeXPosition, planeYPosition, planeZPosition)
        self.sceneView.scene.rootNode.addChildNode(portalNode)
        self.addPlanes(nodeName: "roof", portalNode: portalNode, imageName: "stars")
        self.addPlanes(nodeName: "floor", portalNode: portalNode, imageName: "stars")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "stars")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "stars")
        self.addWalls(nodeName: "sideWallA", portalNode: portalNode, imageName: "stars")
        self.addWalls(nodeName: "sideWallB", portalNode: portalNode, imageName: "stars")
        self.addWalls(nodeName: "backWall", portalNode: portalNode, imageName: "milkyWay")
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetected.isHidden = true
        }
    }
    
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(imageName).jpg")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
            
            
        }
    }
    
    func addPlanes(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(imageName).jpg")
        child?.renderingOrder = 200
    }

}

