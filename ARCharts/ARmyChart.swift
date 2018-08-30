

import SceneKit
import UIKit

public class ARmyChart: SCNNode {
    
    public let series: Int
    public let index: Int
    public let value: Double
    
    public override var description: String {
        return "ARSphereNode(series: \(series), index: \(index), value: \(value))"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(geometry: SCNSphere, index: Int, series: Int, value: Double) {
        self.series = series
        self.index = index
        self.value = value
        super.init()
        self.geometry = geometry
    }
    
}
