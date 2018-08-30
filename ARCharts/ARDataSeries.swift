import Foundation
import SceneKit
import UIKit


public class ARDataSeries: ARSphereChartDataSource, ARSphereChartDelegate {
    
    private let values: [[Double]]
    
    /// Labels to use for the series (Z-axis).
    public var seriesLabels: [String]? = nil
    
    /// Labels to use for the values at each index (X-axis).
    public var indexLabels: [String]? = nil
    
    /// Labels to use for the values(y-axis).
    public var valueLabels: [String]? = nil
    
    /// Colors to use for the charts, cycled through based on chart position.
    public var chartColors: [UIColor]? = nil
    
    /// Materials to use for the charts, cycled through based on chart position.
    /// If non-nil, `chartMaterials` overrides `chartColors` to style the charts.
    public var chartMaterials: [SCNMaterial]? = nil
    
    /// Chamfer radius to use for the charts.
    public var chamferRadius: Float = 0.0
    
    /// Gap between series, expressed as a ratio of gap to chart width (Z-axis).
    public var seriesGap: Float = 0.5
    
    /// Gap between indices, expressed as a ratio of gap to chart length (X-axis).
    public var indexGap: Float = 0.5
    
    /// Space to allow for the series labels, expressed as a ratio of label space to graph width (Z-axis).
    public var spaceForSeriesLabels: Float = 0.2
    
    /// Space to allow for the index labels, expressed as a ratio of label space to graph length (X-axis).
    public var spaceForIndexLabels: Float = 0.2
    
    public var spaceForValueLabels: Float = 0.2
    
    /// Opacity of each chart in the graph.
    public var chartOpacity: Float = 1.0
    
    
    
    // MARK - ARChartDataSource
    
    public required init(withValues values: [[Double]]) {
        self.values = values
    }
    
    public func numberOfSeries(in myChart: ARSphereChart) -> Int {
        return values.count
    }
    
    public func myChart(_ myChart: ARSphereChart, numberOfValuesInSeries series: Int) -> Int {
        return values[series].count
    }
    
    public func myChart(_ myChart: ARSphereChart, valueAtIndex index: Int, forSeries series: Int) -> Double {
        return values[series][index]
    }
    
    public func myChart(_ myChart: ARSphereChart, labelForSeries series: Int) -> String? {
        let label = seriesLabels?[series]
        return label
    }
    
    public func myChart(_ myChart: ARSphereChart, labelForValuesAtIndex index: Int) -> String? {
        return indexLabels?[index]
    }
    
    public func myChart(_ myChart: ARSphereChart, labelForValues index: Int) -> String? {
        return valueLabels?[index]
    }
    
    // MARK - ARChartDelegate
    
    public func myChart(_ myChart: ARSphereChart, colorForChartAtIndex index: Int, forSeries series: Int) -> UIColor {
        if let myColors = chartColors {
            //return myColors[(series * values[series].count + index) % myColors.count]
            return myColors[0]
        }
        
        return UIColor.white
    }
    
    public func myChart(_ myChart: ARSphereChart, materialForChartAtIndex index: Int, forSeries series: Int) -> SCNMaterial {
        if let chartMaterials = chartMaterials {
            return chartMaterials[(series * (values.first?.count ?? 0) + index) % chartMaterials.count]
        }
        
        // If chart materials are not set, default to using colors
        let colorMaterial = SCNMaterial()
        colorMaterial.diffuse.contents = self.myChart(myChart, colorForChartAtIndex: index, forSeries: series)
        colorMaterial.specular.contents = UIColor.white
        return colorMaterial
    }
    
    public func myChart(_ myChart: ARSphereChart, gapSizeAfterSeries series: Int) -> Float {
        return seriesGap
    }
    
    public func myChart(_ myChart: ARSphereChart, gapSizeAfterIndex index: Int) -> Float {
        return indexGap
    }
    
    public func myChart(_ myChart: ARSphereChart, opacityForChartAtIndex index: Int, forSeries series: Int) -> Float {
        return chartOpacity
    }
    
    public func myChart(_ myChart: ARSphereChart, chamferRadiusForChartAtIndex index: Int, forSeries series: Int) -> Float {
        return chamferRadius
    }
    
    public func spaceForSeriesLabels(in myChart: ARSphereChart) -> Float {
        return spaceForSeriesLabels
    }
    
    public func spaceForIndexLabels(in myChart: ARSphereChart) -> Float {
        return spaceForIndexLabels
    }
    
    public func spaceForValueLabels(in myChart: ARSphereChart) -> Float {
        return spaceForValueLabels
    }
    
}
