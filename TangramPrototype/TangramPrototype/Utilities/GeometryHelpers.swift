//
//  GeometryHelpers.swift
//  TangramPrototype
//
//  Created by AI Assistant on 8/3/25.
//  Purpose: Advanced geometric algorithms and helper functions for tangram game logic
//

import SwiftUI
import Foundation

/// Advanced geometric algorithms and utility functions for tangram gameplay
/// Complements the basic Vertex operations with complex geometric calculations
struct GeometryHelpers {
    
    // MARK: - Basic Shape Operations (Subtask 7.1)
    
    /// Calculates the area of a polygon defined by vertices using the shoelace formula
    /// - Parameter vertices: Array of vertices defining the polygon (must be in order)
    /// - Returns: Absolute area of the polygon in square points
    static func polygonArea(vertices: [Vertex]) -> Double {
        guard vertices.count >= 3 else {
            debugLog("⚠️ GeometryHelpers.polygonArea: Need at least 3 vertices, got \(vertices.count)", category: .geometry)
            return 0.0
        }
        
        var area: Double = 0.0
        let n = vertices.count
        
        // Shoelace formula: Area = 0.5 * |Σ(x_i * y_{i+1} - x_{i+1} * y_i)|
        for i in 0..<n {
            let current = vertices[i]
            let next = vertices[(i + 1) % n] // Wrap around to first vertex
            area += current.x * next.y - next.x * current.y
        }
        
        let finalArea = abs(area) / 2.0
        debugLog("🔢 Calculated polygon area: \(String(format: "%.2f", finalArea)) sq pts for \(vertices.count) vertices", category: .geometry)
        
        return finalArea
    }
    
    /// Calculates the centroid (geometric center) of a polygon
    /// - Parameter vertices: Array of vertices defining the polygon
    /// - Returns: Vertex representing the centroid position
    static func polygonCentroid(vertices: [Vertex]) -> Vertex {
        guard !vertices.isEmpty else {
            debugLog("⚠️ GeometryHelpers.polygonCentroid: Empty vertex array", category: .geometry)
            return Vertex()
        }
        
        if vertices.count == 1 {
            return vertices[0]
        }
        
        if vertices.count == 2 {
            return vertices[0].midpoint(to: vertices[1])
        }
        
        // For polygons with 3+ vertices, use weighted centroid formula
        let area = polygonArea(vertices: vertices)
        guard area > 0 else {
            // Fallback to simple average for degenerate polygons
            return simpleVertexAverage(vertices: vertices)
        }
        
        var centroidX: Double = 0.0
        var centroidY: Double = 0.0
        let n = vertices.count
        
        for i in 0..<n {
            let current = vertices[i]
            let next = vertices[(i + 1) % n]
            let crossProduct = current.x * next.y - next.x * current.y
            
            centroidX += (current.x + next.x) * crossProduct
            centroidY += (current.y + next.y) * crossProduct
        }
        
        let factor = 1.0 / (6.0 * area)
        let finalCentroid = Vertex(x: centroidX * factor, y: centroidY * factor)
        
        debugLog("📍 Calculated centroid: (\(String(format: "%.2f", finalCentroid.x)), \(String(format: "%.2f", finalCentroid.y))) for polygon area \(String(format: "%.2f", area))", category: .geometry)
        
        return finalCentroid
    }
    
    /// Simple arithmetic average of vertices (fallback for degenerate cases)
    /// - Parameter vertices: Array of vertices
    /// - Returns: Average position vertex
    private static func simpleVertexAverage(vertices: [Vertex]) -> Vertex {
        let sumX = vertices.reduce(0.0) { $0 + $1.x }
        let sumY = vertices.reduce(0.0) { $0 + $1.y }
        let count = Double(vertices.count)
        
        return Vertex(x: sumX / count, y: sumY / count)
    }
    
    // MARK: - Collision Detection Functions (Subtask 7.2)
    
    /// Tests if a point lies inside a polygon using ray casting algorithm
    /// - Parameters:
    ///   - point: Point to test
    ///   - vertices: Polygon vertices (must be in order, clockwise or counterclockwise)
    /// - Returns: True if point is inside the polygon
    static func pointInPolygon(point: Vertex, vertices: [Vertex]) -> Bool {
        guard vertices.count >= 3 else {
            debugLog("⚠️ GeometryHelpers.pointInPolygon: Need at least 3 vertices for polygon test", category: .geometry)
            return false
        }
        
        var intersections = 0
        let n = vertices.count
        
        // Ray casting: count intersections with polygon edges from point extending right
        for i in 0..<n {
            let current = vertices[i]
            let next = vertices[(i + 1) % n]
            
            // Check if ray crosses this edge
            if rayIntersectsEdge(rayStart: point, edge: (current, next)) {
                intersections += 1
            }
        }
        
        // Point is inside if odd number of intersections
        let isInside = (intersections % 2) == 1
        
        if Constants.Debug.enableGeometryDebug {
            debugLog("🎯 Point (\(String(format: "%.1f", point.x)), \(String(format: "%.1f", point.y))) in polygon: \(isInside) (\(intersections) intersections)", category: .geometry)
        }
        
        return isInside
    }
    
    /// Helper function to test if a horizontal ray intersects a polygon edge
    /// - Parameters:
    ///   - rayStart: Starting point of the ray
    ///   - edge: Tuple of two vertices defining the edge
    /// - Returns: True if ray intersects the edge
    private static func rayIntersectsEdge(rayStart: Vertex, edge: (Vertex, Vertex)) -> Bool {
        let (v1, v2) = edge
        
        // Edge must span the ray's Y coordinate
        guard (v1.y > rayStart.y) != (v2.y > rayStart.y) else {
            return false
        }
        
        // Calculate intersection X coordinate
        let intersectionX = v1.x + (rayStart.y - v1.y) * (v2.x - v1.x) / (v2.y - v1.y)
        
        // Ray extends to the right, so intersection must be to the right of start point
        return intersectionX > rayStart.x
    }
    
    /// Calculates axis-aligned bounding box for a set of vertices
    /// - Parameter vertices: Array of vertices
    /// - Returns: CGRect representing the bounding box
    static func boundingBox(for vertices: [Vertex]) -> CGRect {
        guard !vertices.isEmpty else {
            debugLog("⚠️ GeometryHelpers.boundingBox: Empty vertex array", category: .geometry)
            return CGRect.zero
        }
        
        let minX = vertices.min(by: { $0.x < $1.x })?.x ?? 0
        let maxX = vertices.max(by: { $0.x < $1.x })?.x ?? 0
        let minY = vertices.min(by: { $0.y < $1.y })?.y ?? 0
        let maxY = vertices.max(by: { $0.y < $1.y })?.y ?? 0
        
        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        
        debugLog("📦 Bounding box: (\(String(format: "%.1f", rect.minX)), \(String(format: "%.1f", rect.minY))) to (\(String(format: "%.1f", rect.maxX)), \(String(format: "%.1f", rect.maxY)))", category: .geometry)
        
        return rect
    }
    
    /// Tests if two axis-aligned bounding boxes intersect
    /// - Parameters:
    ///   - box1: First bounding box
    ///   - box2: Second bounding box
    /// - Returns: True if boxes overlap
    static func boundingBoxesIntersect(_ box1: CGRect, _ box2: CGRect) -> Bool {
        let intersects = box1.intersects(box2)
        
        if Constants.Debug.enableGeometryDebug {
            debugLog("📦 Bounding box intersection: \(intersects)", category: .geometry)
        }
        
        return intersects
    }
    
    /// Tests if a circle intersects with a polygon (useful for drag proximity detection)
    /// - Parameters:
    ///   - center: Center point of the circle
    ///   - radius: Radius of the circle
    ///   - vertices: Polygon vertices
    /// - Returns: True if circle intersects the polygon
    static func circleIntersectsPolygon(center: Vertex, radius: Double, vertices: [Vertex]) -> Bool {
        // First check if circle center is inside polygon
        if pointInPolygon(point: center, vertices: vertices) {
            debugLog("🔵 Circle center inside polygon - intersection confirmed", category: .geometry)
            return true
        }
        
        // Check if circle intersects any polygon edge
        let n = vertices.count
        for i in 0..<n {
            let current = vertices[i]
            let next = vertices[(i + 1) % n]
            
            if distanceFromPointToLineSegment(point: center, lineStart: current, lineEnd: next) <= radius {
                debugLog("🔵 Circle intersects polygon edge \(i) - intersection confirmed", category: .geometry)
                return true
            }
        }
        
        debugLog("🔵 Circle does not intersect polygon", category: .geometry)
        return false
    }
    
    /// Calculates the shortest distance from a point to a line segment
    /// - Parameters:
    ///   - point: Point to measure from
    ///   - lineStart: Start vertex of line segment
    ///   - lineEnd: End vertex of line segment
    /// - Returns: Shortest distance in points
    static func distanceFromPointToLineSegment(point: Vertex, lineStart: Vertex, lineEnd: Vertex) -> Double {
        let lineLength = lineStart.distance(to: lineEnd)
        
        // Handle degenerate case where line segment is actually a point
        guard lineLength > Constants.Geometry.minimumVertexSeparation else {
            return point.distance(to: lineStart)
        }
        
        // Calculate parametric position along line segment (0 = start, 1 = end)
        let dx = lineEnd.x - lineStart.x
        let dy = lineEnd.y - lineStart.y
        let t = ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / (lineLength * lineLength)
        
        // Clamp t to [0, 1] to stay within line segment
        let clampedT = max(0.0, min(1.0, t))
        
        // Find closest point on line segment
        let closestPoint = Vertex(
            x: lineStart.x + clampedT * dx,
            y: lineStart.y + clampedT * dy
        )
        
        let distance = point.distance(to: closestPoint)
        
        if Constants.Debug.enableGeometryDebug {
            debugLog("📏 Distance from point to line segment: \(String(format: "%.2f", distance)) (t=\(String(format: "%.3f", clampedT)))", category: .geometry)
        }
        
        return distance
    }
    
    /// Efficient broad-phase collision filtering using spatial partitioning
    /// - Parameters:
    ///   - pieces: Array of game pieces to test
    ///   - testPoint: Point to test against pieces
    ///   - maxDistance: Maximum distance for consideration
    /// - Returns: Array of pieces within the specified distance
    static func piecesNearPoint(_ pieces: [Piece], testPoint: Vertex, maxDistance: Double) -> [Piece] {
        return pieces.filter { piece in
            let pieceCenter = Vertex(from: piece.position)
            let distance = testPoint.distance(to: pieceCenter)
            let isNear = distance <= maxDistance
            
            if Constants.Debug.enableGeometryDebug && isNear {
                debugLog("🔍 Piece \(piece.type) is near test point (distance: \(String(format: "%.1f", distance)))", category: .geometry)
            }
            
            return isNear
        }
    }
}

// MARK: - Debug Extensions

extension GeometryHelpers {
    
    /// Validates geometric consistency for a polygon
    /// - Parameter vertices: Vertices to validate
    /// - Returns: True if polygon is geometrically valid
    static func validatePolygon(vertices: [Vertex]) -> Bool {
        guard vertices.count >= 3 else {
            debugLog("❌ Invalid polygon: Need at least 3 vertices", category: .geometry)
            return false
        }
        
        // Check for minimum vertex separation
        for i in 0..<vertices.count {
            let current = vertices[i]
            let next = vertices[(i + 1) % vertices.count]
            
            if current.distance(to: next) < Constants.Geometry.minimumVertexSeparation {
                debugLog("❌ Invalid polygon: Vertices too close at index \(i)", category: .geometry)
                return false
            }
        }
        
        let area = polygonArea(vertices: vertices)
        if area < 1.0 { // Minimum reasonable area
            debugLog("❌ Invalid polygon: Area too small (\(String(format: "%.3f", area)))", category: .geometry)
            return false
        }
        
        debugLog("✅ Polygon validation passed: \(vertices.count) vertices, area \(String(format: "%.2f", area))", category: .geometry)
        return true
    }
}