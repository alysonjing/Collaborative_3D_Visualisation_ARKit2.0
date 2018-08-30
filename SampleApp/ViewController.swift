import ARCharts
import ARKit
import SceneKit
import UIKit

import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate, SettingsDelegate, UIPopoverPresentationControllerDelegate, ARSessionDelegate {
    
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sendMapButton: UIButton!
    
    var multipeerSession: MultipeerSession!
    
    var myChart: ARSphereChart?

        private let arKitColors = [
            [UIColor(red: 1.00, green: 0.87, blue: 0.33, alpha: 1.0)],
            [UIColor(red: 0.07, green: 0.55, blue: 0.53, alpha: 1.0)],
            [UIColor(red: 0.78, green: 0.25, blue: 0.18, alpha: 1.0)],
            [UIColor(red: 0.48, green: 0.75, blue: 0.38, alpha: 1.0)],
            [UIColor(red: 0.54, green: 0.65, blue: 0.80, alpha: 1.0)],
            [UIColor(red: 0.81, green: 0.45, blue: 0.68, alpha: 1.0)],
            
        ]
    
    var values = [[[Double]]]()
    
    var session: ARSession {
        return sceneView.session
    }
    
    var screenCenter: CGPoint?
    var settings = Settings()
    var dataSeries: ARDataSeries?
    let configuration = ARWorldTrackingConfiguration()
    var charti: Int = 0  //chart iteration - to constrain chart node
    var datai: Int = 0
    var colori: Int = 0
    var shareSessionCalled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.showsStatistics = false
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
        sceneView.contentScaleFactor = 1.0
        sceneView.preferredFramesPerSecond = 60
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
        
        setupFocusSquare()
        setupRotationGesture()
        setupPinchGesture()
        setupTapGesture()
        
        addLightSource(ofType: .omni)
        
        values.append( [[6.0, 10.0, 12.0, 8.0, 15.0, 13.0],
                        [10.0, 13.0, 18.0, 20.0, 25.0, 23.0],
                        [25.0, 30.0, 35.0, 28.0, 33.0, 31.0],
                        [35.0, 40.0, 45.0, 43.0, 38.0, 39.0],
                        [45.0, 55.0, 50.0, 52.0, 53.0, 48.0],
                        [55.0, 65.0, 63.0, 60.0, 58.0, 57.0]])
        
        values.append([[55.0, 65.0, 63.0, 60.0, 58.0, 57.0],
                       [45.0, 55.0, 50.0, 52.0, 53.0, 48.0],
                       [5.0, 2.0, 5.0, 3.0, 3.0, 9.0],
                       [2.0, 3.0, 5.0, 2.0, 3.0, 1.0],
                       [1.0, 3.0, 1.0, 2.0, 5.0, 3.0],
                       [6.0, 1.0, 2.0, 8.0, 5.0, 3.0]])
        
        values.append([[35.0, 40.0, 45.0, 43.0, 38.0, 39.0],
                       [45.0, 55.0, 50.0, 52.0, 53.0, 48.0],
                       [55.0, 65.0, 63.0, 60.0, 58.0, 57.0],
                       [25.0, 60.0, 70.0, 68.0, 63.0, 71.0],
                       [55.0, 50.0, 58.0, 20.0, 25.0, 23.0],
                       [6.0, 1.0, 2.0, 8.0, 5.0, 3.0]])
        
        values.append([[5.0, 6.0, 3.0, 6.0, 5.0, 7.0],
                       [2.0, 3.0, 3.0, 2.0, 3.0, 1.0],
                       [6.0, 1.0, 2.0, 8.0, 5.0, 3.0],
                       [5.0, 3.0, 5.0, 2.0, 3.0, 3.0],
                       [5.0, 6.0, 3.0, 6.0, 5.0, 7.0],
                       [1.0, 3.0, 3.0, 4.0, 2.0, 7.0]])
        
        values.append( [[6.0, 1.0, 2.0, 3.0, 5.0, 3.0],
                        [1.0, 3.0, 1.0, 2.0, 5.0, 3.0],
                        [55.0, 60.0, 65.0, 68.0, 53.0, 61.0],
                        [65.0, 70.0, 65.0, 63.0, 58.0, 69.0],
                        [55.0, 65.0, 50.0, 62.0, 53.0, 58.0],
                        [55.0, 65.0, 63.0, 60.0, 58.0, 57.0]])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        

        self.configuration.planeDetection = .horizontal
        sceneView.session.configuration?.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self

        UIApplication.shared.isIdleTimerDisabled = true
        
        screenCenter = self.sceneView.bounds.mid
        chartButton.layer.cornerRadius = 40.0
        chartButton.clipsToBounds = true
        removeButton.layer.cornerRadius = 40.0
        removeButton.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    var focusSquare = FocusSquare()
    func setupFocusSquare() {
        focusSquare.isHidden = true
        focusSquare.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }
    
    //add a new chart
    @IBAction func add(_ sender: Any) {
        guard let worldTransformAnchor = getWorldTransformAnchor() else {
            let alert = UIAlertController(title: "World tracking not complete", message: "Move around more to map", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: worldTransformAnchor, requiringSecureCoding: true)
            else {
                let alert = UIAlertController(title: "Cannot encode anchor", message: "Restart and try again", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        self.multipeerSession.sendToAllPeers(data)
        sceneView.session.add(anchor: worldTransformAnchor)
    }
    
    //remove all charts
    @IBAction func removeAll(_ sender: UIButton) {
        restartSession()
        let message: String = "removeall"
        let data = message.data(using: .utf8)!
        
        self.multipeerSession.sendToAllPeers(data)
    }
    //remove all chart node func
    func restartSession(){
        // Enumerate through all child nodes for rootNode as parent and delete all of those in Chart
        self.sceneView.scene.rootNode.enumerateChildNodes { (node,_) in
            if (node.name?.range(of:"chart") != nil) {
                node.removeFromParentNode()
            }
        }
    }
    
    private func addmyChart() -> ARSphereChart? {
        values.append (generateRandomNumbers(withRange: 0..<50, numberOfRows: settings.numberOfSeries, numberOfColumns: settings.numberOfIndices))

        var seriesLabels = Array(0..<values.count).map({ "Month \($0 + 1)" })
        var indexLabels = Array(0..<values.count).map({ "Day \($0 + 1)" })
        var valueLabels = Array(0..<50).map({ "Value \($0)" })
        
        
        if settings.dataSet > 0 {
            seriesLabels = parseSeriesLabels(fromDataSampleWithIndex: settings.dataSet - 1) ?? seriesLabels
            indexLabels = parseIndexLabels(fromDataSampleWithIndex: settings.dataSet - 1) ?? indexLabels
            valueLabels = parseValueLabels(fromDataSampleWithIndex: settings.dataSet - 1) ?? valueLabels
        }
        
        dataSeries = ARDataSeries(withValues: values[datai])
        if settings.showLabels {
            dataSeries?.seriesLabels = seriesLabels
            dataSeries?.indexLabels = indexLabels
            dataSeries?.valueLabels = valueLabels
            
            dataSeries?.spaceForIndexLabels = 0.2
            dataSeries?.spaceForIndexLabels = 0.2
            dataSeries?.spaceForIndexLabels = 0.1
            
            
        } else {
            dataSeries?.spaceForIndexLabels = 0.0
            dataSeries?.spaceForIndexLabels = 0.0
            dataSeries?.spaceForIndexLabels = 0.0
        }
        
        datai+=1
        
        dataSeries?.chartColors = arKitColors[colori % 6]
        colori+=1
        
        myChart = ARSphereChart()
        myChart?.name = "chart" + String(charti)
        charti += 1
        if let myChart = myChart {
            myChart.dataSource = dataSeries
            myChart.delegate = dataSeries
            setupGraph()
            myChart.draw()
        }
        return myChart
    }
    
    private func addLightSource(ofType type: SCNLight.LightType, at position: SCNVector3? = nil) {
        let light = SCNLight()
        light.color = UIColor.white
        light.type = type
        light.intensity = 1500 // Default SCNLight intensity is 1000
        
        let lightNode = SCNNode()
        lightNode.light = light
        if let lightPosition = position {
            // Fix the light source in one location
            lightNode.position = lightPosition
            self.sceneView.scene.rootNode.addChildNode(lightNode)
        } else {
            // Make the light source follow the camera position
            self.sceneView.pointOfView?.addChildNode(lightNode)
        }
    }
    
    private func setupRotationGesture() {
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        self.view.addGestureRecognizer(rotationGestureRecognizer)
    }
    
    private func setupPinchGesture() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    private func setupTapGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let name = anchor.name, name.hasPrefix("chart") {
            node.addChildNode(addmyChart()!)
        }
    }
    
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            sendMapButton.isEnabled = false
        case .extending:
            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        case .mapped:
            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        //resetTracking(nil)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    
    
    
    // MARK: - Multiuser shared session
    /// - Tag: GetWorldMap
    @IBAction func shareSession(_ sender: UIButton) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else {
                    let alert = UIAlertController(title: "Cannot encode map", message: "Restart and try again", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
            }
            self.multipeerSession.sendToAllPeers(data)
            self.shareSessionCalled = true
        }
    }
    
    var mapProvider: MCPeerID?
    
    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        
        if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(of: ARWorldMap.classForKeyedUnarchiver(), from: data),
            let worldMap = unarchived as? ARWorldMap {
            
            // Run the session with the received world map.
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
            // Remember who provided the map for showing UI feedback.
            mapProvider = peer
        }
        else
            if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(of: ARAnchor.classForKeyedUnarchiver(), from: data),
                let anchor = unarchived as? ARAnchor {
                sceneView.session.add(anchor: anchor)
                
            }
            else
                if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(of: PositionChange.classForKeyedUnarchiver(), from: data),
                    let position = unarchived as? PositionChange {
                    guard let newChart = myChart else {
                        return
                    }
                    newChart.position = SCNVector3Make(position.x, position.y, position.z)
                    sceneView.scene.rootNode.addChildNode(newChart)
                }
                else
                    if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(of: ScaleChange.classForKeyedUnarchiver(), from: data),
                        let scale = unarchived as? ScaleChange {
                        guard let newChart = myChart else {
                            return
                        }
                        newChart.scale = SCNVector3Make(scale.x, scale.y, scale.z)
                    }
                    else
                        if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(of: AngleChange.classForKeyedUnarchiver(), from: data),
                            let angle = unarchived as? AngleChange {
                            guard let newChart = myChart else {
                                return
                            }
                            newChart.eulerAngles.y = angle.x - angle.y
                            
                        }
                        else if
                            String(data: data, encoding: .utf8)! == "removeall"
                        {
                            print("string succeed") //debug reference
                            self.sceneView.scene.rootNode.enumerateChildNodes { (node,_) in
                                if (node.name?.range(of:"chart") != nil) {
                                    node.removeFromParentNode()
                                }
                            }
                        }
                        else {
                            print("unknown data recieved from \(peer)")
        }
    }
    
    // MARK: - AR session management
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move around to map the environment, or wait to join a shared session."
            
        case .normal where shareSessionCalled==true:
            message = "Shared with your collaborators"
            
        case .normal where !multipeerSession.connectedPeers.isEmpty && mapProvider == nil:
            let peerNames = multipeerSession.connectedPeers.map({ $0.displayName }).joined(separator: ", ")
            message = "Connected with \(peerNames)."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing) where mapProvider != nil,
             .limited(.relocalizing) where mapProvider != nil:
            message = "Received map from \(mapProvider!.displayName)."
            
        case .limited(.relocalizing):
            message = "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = "Waiting for your action."
            
        }
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    //MARK: Reset world button control
    @IBAction func resetWorld(_ sender: UIButton) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Interaction gestures
    private var startingRotation: Float = 0.0
    
    @objc func handleRotation(rotationGestureRecognizer: UIRotationGestureRecognizer) {  //rotate
        guard let newChart = myChart,
            
            let pointOfView = sceneView.pointOfView,
            sceneView.isNode(newChart, insideFrustumOf: pointOfView) == true else {
                return
        }
        
        if rotationGestureRecognizer.state == .began {
            startingRotation = newChart.eulerAngles.y
        } else if rotationGestureRecognizer.state == .changed {
            self.myChart?.eulerAngles.y = startingRotation - Float(rotationGestureRecognizer.rotation)
            
            let newAngleObject = AngleChange(x: startingRotation, y: Float(rotationGestureRecognizer.rotation))
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newAngleObject, requiringSecureCoding: true)
                else {
                    let alert = UIAlertController(title: "Cannot encode rotation", message: "Restart and try again", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
            }
            self.multipeerSession.sendToAllPeers(data)
            print("new angle", Float(rotationGestureRecognizer.rotation))
            
        }
    }
    
    @objc func handlePinch(pinchGestureRecognizer: UIPinchGestureRecognizer) {  //pinch
        
        guard let newChart = myChart,
            let pointOfView = sceneView.pointOfView,
            sceneView.isNode(newChart, insideFrustumOf: pointOfView) == true else {
                return
        }
        var originalScale = myChart?.scale
        
        switch pinchGestureRecognizer.state {
        case .began:
            originalScale = myChart?.scale
            pinchGestureRecognizer.scale = CGFloat((myChart?.scale.x)!)
        case .changed:
            guard var newScale = originalScale else { return }
            if pinchGestureRecognizer.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if pinchGestureRecognizer.scale > 5{
                newScale = SCNVector3(5, 5, 5)
            }else{
                newScale = SCNVector3(pinchGestureRecognizer.scale, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale)
            }
            myChart?.scale = newScale
     
            let newScaleObject = ScaleChange(x: (myChart?.scale.x)!, y: (myChart?.scale.y)!, z: (myChart?.scale.z)!)
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newScaleObject, requiringSecureCoding: true)
                else {
                    let alert = UIAlertController(title: "Cannot encode scale", message: "Restart and try again", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
            }
            self.multipeerSession.sendToAllPeers(data)
            print("new scale", newScale)
        case .ended:
            guard var newScale = originalScale else { return }
            if pinchGestureRecognizer.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if pinchGestureRecognizer.scale > 5{
                newScale = SCNVector3(5, 5, 5)
            }else{
                newScale = SCNVector3(pinchGestureRecognizer.scale, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale)
            }
            myChart?.scale = newScale
            pinchGestureRecognizer.scale = CGFloat((myChart?.scale.x)!)
            
        default:
            pinchGestureRecognizer.scale = 1.0
            originalScale = nil
        }
        
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {  //tap
        
        guard let newChart = myChart,
            let pointOfView = sceneView.pointOfView,
            sceneView.isNode(newChart, insideFrustumOf: pointOfView) == true else {
                return
        }
        
        let tapLocation = gestureRecognizer.location(in: sceneView)
        let results = sceneView.hitTest(tapLocation, types: .featurePoint)
        
        if let result = results.first {
            let translation = result.worldTransform.translation
            newChart.position = SCNVector3Make(translation.x, translation.y, translation.z)
            let newPositionObject = PositionChange(x: translation.x, y: translation.y, z: translation.z)
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newPositionObject, requiringSecureCoding: true)
                else {
                    let alert = UIAlertController(title: "Cannot encode position", message: "Restart and try again", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
            }
            self.multipeerSession.sendToAllPeers(data)
            sceneView.scene.rootNode.addChildNode(newChart)
        }
        
    }
    
    // MARK: - Focus square (yellow circle)
    func updateFocusSquare() {
        guard let screenCenter = screenCenter else {
            return
        }
        focusSquare.isHidden = false
        focusSquare.unhide()
        
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare.position)
        if let worldPos = worldPos {
            focusSquare.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
        }
    }
    
    var dragOnInfinitePlanesEnabled = false
    
    func getWorldTransformAnchor() -> ARAnchor? {
        
        guard let hitTestResult = sceneView
            .hitTest(self.screenCenter!, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first else { return nil }
        
        return ARAnchor(name: "chart", transform: hitTestResult.worldTransform)
    }
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor
            
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
            
            let pointOnPlane = objectPos ?? SCNVector3Zero
            
            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
    private func setupGraph() {
        myChart?.size = SCNVector3(settings.graphWidth, settings.graphHeight, settings.graphLength)
    }        
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: SettingsDelegate
    func didUpdateSettings(_ settings: Settings) {
        self.settings = settings
        myChart?.removeFromParentNode()
        myChart = nil
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

func generateRandomColor() -> UIColor {
    let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
    let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
    let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
    
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    
}
