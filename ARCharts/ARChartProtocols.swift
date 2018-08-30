import SceneKit
import UIKit


public protocol ARSphereChartDataSource: class {
    

    func numberOfSeries(in myChart: ARSphereChart) -> Int

    func myChart(_ myChart: ARSphereChart,
                  numberOfValuesInSeries series: Int) -> Int

    func myChart(_ myChart: ARSphereChart,
                  valueAtIndex index: Int,
                  forSeries series: Int) -> Double
    
    func myChart(_ myChart: ARSphereChart,
                  labelForSeries series: Int) -> String?

    func myChart(_ myChart: ARSphereChart,
                  labelForValuesAtIndex index: Int) -> String?
    
    
    func myChart(_ myChart: ARSphereChart,
                 labelForValues value: Int) -> String?
    
}

// Make it optional for an `ARChartDataSource` to provide labels.
extension ARSphereChartDataSource {
    
    public func myChart(_ myChart: ARSphereChart, labelForSeries series: Int) -> String? {
        return nil
    }
    
    public func myChart(_ myChart: ARSphereChart, labelForValuesAtIndex index: Int) -> String? {
        return nil
    }
    
}

public protocol ARSphereChartDelegate: class {
    
    func myChart(_ myChart: ARSphereChart,
                  colorForChartAtIndex index: Int,
                  forSeries series: Int) -> UIColor

    func myChart(_ myChart: ARSphereChart,
                  opacityForChartAtIndex index: Int,
                  forSeries series: Int) -> Float

    func myChart(_ myChart: ARSphereChart,
                  colorForLabelForSeries series: Int) -> UIColor

    func myChart(_ myChart: ARSphereChart,
                  colorForLabelForValuesAtIndex index: Int) -> UIColor
    
    func myChart(_ myChart: ARSphereChart,
                  backgroundColorForLabelForSeries series: Int) -> UIColor

    func myChart(_ myChart: ARSphereChart,
                  backgroundColorForLabelForValuesAtIndex index: Int) -> UIColor
    
    func myChart(_ myChart: ARSphereChart,
                  gapSizeAfterSeries series: Int) -> Float

    func myChart(_ myChart: ARSphereChart,
                  gapSizeAfterIndex index: Int) -> Float

    func myChart(_ myChart: ARSphereChart,
                  materialForChartAtIndex index: Int,
                  forSeries series: Int) -> SCNMaterial

    func myChart(_ myChart: ARSphereChart,
                  chamferRadiusForChartAtIndex index: Int,
                  forSeries series: Int) -> Float

    func spaceForIndexLabels(in myChart: ARSphereChart) -> Float

    func spaceForSeriesLabels(in myChart: ARSphereChart) -> Float
    
}

extension ARSphereChartDelegate {
    
    public func myChart(_ myChart: ARSphereChart,
                         materialForChartAtIndex index: Int,
                         forSeries series: Int) -> SCNMaterial {
        let colorMaterial = SCNMaterial()
        colorMaterial.diffuse.contents = self.myChart(myChart, colorForChartAtIndex: index, forSeries: series)
        return colorMaterial
    }
    
    func myChart(_ myChart: ARSphereChart,
                  chamferRadiusForChartAtIndex index: Int,
                  forSeries series: Int) -> Float {
        return 0.0
    }
    
    public func myChart(_ myChart: ARSphereChart,
                         gapSizeAfterSeries series: Int) -> Float {
        return 0.0
    }
        
    public func spaceForIndexLabels(in myChart: ARSphereChart) -> Float {
        return 0.0
    }
    
    public func spaceForSeriesLabels(in myChart: ARSphereChart) -> Float {
        return 0.0
    }
    
    public func myChart(_ myChart: ARSphereChart,
                         gapSizeAfterIndex index: Int) -> Float {
        return 0.0
    }
    
    public func myChart(_ myChart: ARSphereChart,
                         colorForChartAtIndex index: Int,
                         forSeries series: Int) -> UIColor {
        return UIColor.white
    }
        
    public func myChart(_ myChart: ARSphereChart,
                         colorForLabelForSeries series: Int) -> UIColor {
        return UIColor.white
    }
    
    func myChart(_ myChart: ARSphereChart,
                  opacityForChartAtIndex index: Int,
                  forSeries series: Int) -> Float {
        return 1.0
    }
    
    public func myChart(_ myChart: ARSphereChart, colorForLabelForValuesAtIndex index: Int) -> UIColor {
        return UIColor.white
    }
    
    public func myChart(_ myChart: ARSphereChart, backgroundColorForLabelForValuesAtIndex index: Int) -> UIColor {
        return UIColor.clear
    }
    
    public func myChart(_ myChart: ARSphereChart, backgroundColorForLabelForSeries series: Int) -> UIColor {
        return UIColor.clear
    }
    
    
    
}
