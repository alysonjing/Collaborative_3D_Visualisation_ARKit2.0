import Foundation
import SceneKit

public class PositionChange: NSObject, NSSecureCoding{

    public var x: Float = 0.0
    public var y: Float = 0.0
    public var z: Float = 0.0

    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    // Here you will try to initialize an object from archve using keys you did set in `encode` method.
    public convenience required init?(coder decoder: NSCoder) {
        let x = decoder.decodeFloat(forKey: "x")
        let y = decoder.decodeFloat(forKey: "y")
        let z = decoder.decodeFloat(forKey: "z")
        self.init(x: x,y: y,z: z)
    }
    
    // Here you need to sKeyet properties to specific keys in archive
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.x, forKey: "x")
        aCoder.encode(self.y, forKey: "y")
        aCoder.encode(self.z, forKey: "z")
    }
    
    public static var supportsSecureCoding: Bool {
        return true;
    }
}

    

    

