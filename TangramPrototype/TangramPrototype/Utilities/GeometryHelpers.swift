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
    
    // MARK: - Transformation Functions (Subtask 7.3)
    
    /// Rotates a vertex around an arbitrary pivot point by the specified angle
    /// - Parameters:
    ///   - vertex: The vertex to rotate
    ///   - pivot: The center point of rotation
    ///   - angle: Rotation angle in radians (positive = counterclockwise)
    /// - Returns: New vertex at the rotated position
    static func rotateVertex(_ vertex: Vertex, around pivot: Vertex, by angle: Double) -> Vertex {
        debugLog("🔄 GeometryHelpers.rotateVertex: Rotating (\(vertex.x), \(vertex.y)) around (\(pivot.x), \(pivot.y)) by \(angle) radians", category: .geometry)
        
        // Translate to origin
        let translatedX = vertex.x - pivot.x
        let translatedY = vertex.y - pivot.y
        
        // Apply rotation matrix
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        
        let rotatedX = translatedX * cosAngle - translatedY * sinAngle
        let rotatedY = translatedX * sinAngle + translatedY * cosAngle
        
        // Translate back
        let finalX = rotatedX + pivot.x
        let finalY = rotatedY + pivot.y
        
        debugLog("🔄 GeometryHelpers.rotateVertex: Result (\(finalX), \(finalY))", category: .geometry)
        return Vertex(x: finalX, y: finalY)
    }
    
    /// Rotates an array of vertices around a pivot point
    /// - Parameters:
    ///   - vertices: Array of vertices to rotate
    ///   - pivot: The center point of rotation
    ///   - angle: Rotation angle in radians (positive = counterclockwise)
    /// - Returns: Array of rotated vertices
    static func rotateVertices(_ vertices: [Vertex], around pivot: Vertex, by angle: Double) -> [Vertex] {
        debugLog("🔄 GeometryHelpers.rotateVertices: Rotating \(vertices.count) vertices by \(angle) radians", category: .geometry)
        return vertices.map { rotateVertex($0, around: pivot, by: angle) }
    }
    
    /// Scales a vertex relative to an origin point
    /// - Parameters:
    ///   - vertex: The vertex to scale
    ///   - origin: The origin point for scaling (typically center or (0,0))
    ///   - scale: Scale factor (1.0 = no change, 2.0 = double size, 0.5 = half size)
    /// - Returns: New vertex at the scaled position
    static func scaleVertex(_ vertex: Vertex, from origin: Vertex, by scale: Double) -> Vertex {
        debugLog("📏 GeometryHelpers.scaleVertex: Scaling (\(vertex.x), \(vertex.y)) from (\(origin.x), \(origin.y)) by \(scale)", category: .geometry)
        
        let scaledX = origin.x + (vertex.x - origin.x) * scale
        let scaledY = origin.y + (vertex.y - origin.y) * scale
        
        return Vertex(x: scaledX, y: scaledY)
    }
    
    /// Scales an array of vertices relative to an origin point
    /// - Parameters:
    ///   - vertices: Array of vertices to scale
    ///   - origin: The origin point for scaling
    ///   - scale: Scale factor for all vertices
    /// - Returns: Array of scaled vertices
    static func scaleVertices(_ vertices: [Vertex], from origin: Vertex, by scale: Double) -> [Vertex] {
        debugLog("📏 GeometryHelpers.scaleVertices: Scaling \(vertices.count) vertices by \(scale)", category: .geometry)
        return vertices.map { scaleVertex($0, from: origin, by: scale) }
    }
    
    /// Translates (moves) a vertex by the specified offset
    /// - Parameters:
    ///   - vertex: The vertex to translate
    ///   - offset: The translation vector (dx, dy)
    /// - Returns: New vertex at the translated position
    static func translateVertex(_ vertex: Vertex, by offset: Vertex) -> Vertex {
        return Vertex(x: vertex.x + offset.x, y: vertex.y + offset.y)
    }
    
    /// Translates (moves) an array of vertices by the specified offset
    /// - Parameters:
    ///   - vertices: Array of vertices to translate
    ///   - offset: The translation vector to apply to all vertices
    /// - Returns: Array of translated vertices
    static func translateVertices(_ vertices: [Vertex], by offset: Vertex) -> [Vertex] {
        debugLog("➡️ GeometryHelpers.translateVertices: Translating \(vertices.count) vertices by (\(offset.x), \(offset.y))", category: .geometry)
        return vertices.map { translateVertex($0, by: offset) }
    }
    
    /// Applies a combined transformation (translate, rotate, scale) to vertices
    /// - Parameters:
    ///   - vertices: Array of vertices to transform
    ///   - translation: Translation offset to apply first
    ///   - rotation: Rotation angle in radians around the centroid
    ///   - scale: Scale factor around the centroid
    /// - Returns: Array of fully transformed vertices
    static func transformVertices(_ vertices: [Vertex], 
                                translation: Vertex = Vertex(x: 0, y: 0),
                                rotation: Double = 0,
                                scale: Double = 1.0) -> [Vertex] {
        debugLog("🔄 GeometryHelpers.transformVertices: Applying combined transform (translate: \(translation), rotate: \(rotation), scale: \(scale))", category: .geometry)
        
        // Step 1: Translate
        var transformed = translateVertices(vertices, by: translation)
        
        // Step 2: Rotate around centroid (if rotation specified)
        if rotation != 0 {
            let centroid = polygonCentroid(vertices: transformed)
            transformed = rotateVertices(transformed, around: centroid, by: rotation)
        }
        
        // Step 3: Scale around centroid (if scale != 1.0)
        if scale != 1.0 {
            let centroid = polygonCentroid(vertices: transformed)
            transformed = scaleVertices(transformed, from: centroid, by: scale)
        }
        
        return transformed
    }
    
    // MARK: - Shape Matching/Comparison Functions (Subtask 7.4)
    
    /// Determines if two polygons have the same shape (ignoring position, rotation, and scale)
    /// Uses normalized shape comparison with area ratios and vertex count
    /// - Parameters:
    ///   - vertices1: First polygon vertices
    ///   - vertices2: Second polygon vertices
    ///   - tolerance: Allowed deviation for floating point comparisons (default: 1e-6)
    /// - Returns: True if the shapes are geometrically similar
    static func areShapesSimilar(_ vertices1: [Vertex], _ vertices2: [Vertex], tolerance: Double = 1e-6) -> Bool {
        debugLog("🔍 GeometryHelpers.areShapesSimilar: Comparing shapes with \(vertices1.count) and \(vertices2.count) vertices", category: .geometry)
        
        // Quick checks
        guard vertices1.count == vertices2.count && vertices1.count >= 3 else {
            debugLog("🔍 Shape similarity: Different vertex counts or insufficient vertices", category: .geometry)
            return false
        }
        
        // Calculate normalized shape descriptors
        let area1 = polygonArea(vertices: vertices1)
        let area2 = polygonArea(vertices: vertices2)
        
        guard area1 > tolerance && area2 > tolerance else {
            debugLog("🔍 Shape similarity: One or both shapes have zero area", category: .geometry)
            return false
        }
        
        // Normalize both shapes to unit area and compare relative distances
        let normalizedVertices1 = normalizeShapeToUnitArea(vertices1)
        let normalizedVertices2 = normalizeShapeToUnitArea(vertices2)
        
        // Try different rotational alignments to account for vertex ordering
        let rotationSteps = vertices1.count
        for startOffset in 0..<rotationSteps {
            if areNormalizedShapesEqual(normalizedVertices1, normalizedVertices2, startOffset: startOffset, tolerance: tolerance) {
                debugLog("🔍 Shape similarity: Match found at offset \(startOffset)", category: .geometry)
                return true
            }
        }
        
        debugLog("🔍 Shape similarity: No match found", category: .geometry)
        return false
    }
    
    /// Calculates what percentage of polygon1 overlaps with polygon2
    /// - Parameters:
    ///   - vertices1: First polygon vertices
    ///   - vertices2: Second polygon vertices
    ///   - sampleDensity: Number of sample points per unit area for approximation (default: 100)
    /// - Returns: Overlap percentage (0.0 to 1.0) where 1.0 means complete overlap
    static func calculateShapeOverlap(_ vertices1: [Vertex], _ vertices2: [Vertex], sampleDensity: Int = 100) -> Double {
        debugLog("🔍 GeometryHelpers.calculateShapeOverlap: Calculating overlap between polygons", category: .geometry)
        
        guard vertices1.count >= 3 && vertices2.count >= 3 else {
            debugLog("🔍 Shape overlap: Insufficient vertices", category: .geometry)
            return 0.0
        }
        
        // Get bounding boxes to determine sampling area
        let bbox1 = boundingBox(for: vertices1)
        let bbox2 = boundingBox(for: vertices2)
        
        // Create combined bounding box
        let minX = min(bbox1.minX, bbox2.minX)
        let maxX = max(bbox1.maxX, bbox2.maxX)
        let minY = min(bbox1.minY, bbox2.minY)
        let maxY = max(bbox1.maxY, bbox2.maxY)
        
        let width = maxX - minX
        let height = maxY - minY
        
        guard width > 0 && height > 0 else {
            debugLog("🔍 Shape overlap: Zero-area bounding box", category: .geometry)
            return 0.0
        }
        
        // Calculate sample grid
        let samplesX = max(10, Int(sqrt(Double(sampleDensity) * width / height)))
        let samplesY = max(10, Int(sqrt(Double(sampleDensity) * height / width)))
        
        let stepX = width / Double(samplesX - 1)
        let stepY = height / Double(samplesY - 1)
        
        var totalSamples = 0
        var overlapSamples = 0
        var shape1Samples = 0
        
        // Sample points across the combined bounding box
        for i in 0..<samplesX {
            for j in 0..<samplesY {
                let samplePoint = Vertex(
                    x: minX + Double(i) * stepX,
                    y: minY + Double(j) * stepY
                )
                
                let inShape1 = pointInPolygon(point: samplePoint, vertices: vertices1)
                let inShape2 = pointInPolygon(point: samplePoint, vertices: vertices2)
                
                totalSamples += 1
                
                if inShape1 {
                    shape1Samples += 1
                    if inShape2 {
                        overlapSamples += 1
                    }
                }
            }
        }
        
        guard shape1Samples > 0 else {
            debugLog("🔍 Shape overlap: No samples found in first shape", category: .geometry)
            return 0.0
        }
        
        let overlapPercentage = Double(overlapSamples) / Double(shape1Samples)
        debugLog("🔍 Shape overlap: \(overlapPercentage * 100)% overlap (\(overlapSamples)/\(shape1Samples) samples)", category: .geometry)
        
        return overlapPercentage
    }
    
    /// Finds the best rotational alignment between two similar shapes
    /// - Parameters:
    ///   - vertices1: Reference shape vertices
    ///   - vertices2: Shape to align with reference
    ///   - angleSteps: Number of rotation angles to test (default: 36, i.e., 10-degree steps)
    /// - Returns: Optimal rotation angle in radians for best alignment
    static func findOptimalAlignment(_ vertices1: [Vertex], _ vertices2: [Vertex], angleSteps: Int = 36) -> Double {
        debugLog("🔍 GeometryHelpers.findOptimalAlignment: Finding optimal rotation between shapes", category: .geometry)
        
        guard vertices1.count >= 3 && vertices2.count >= 3 else {
            debugLog("🔍 Optimal alignment: Insufficient vertices", category: .geometry)
            return 0.0
        }
        
        let centroid1 = polygonCentroid(vertices: vertices1)
        let centroid2 = polygonCentroid(vertices: vertices2)
        
        var bestAngle = 0.0
        var bestOverlap = 0.0
        
        let angleStep = 2.0 * .pi / Double(angleSteps)
        
        for i in 0..<angleSteps {
            let testAngle = Double(i) * angleStep
            
            // Rotate vertices2 around its centroid by testAngle
            let rotatedVertices2 = rotateVertices(vertices2, around: centroid2, by: testAngle)
            
            // Translate to align centroids
            let offset = Vertex(x: centroid1.x - centroid2.x, y: centroid1.y - centroid2.y)
            let alignedVertices2 = translateVertices(rotatedVertices2, by: offset)
            
            // Calculate overlap
            let overlap = calculateShapeOverlap(vertices1, alignedVertices2, sampleDensity: 50)
            
            if overlap > bestOverlap {
                bestOverlap = overlap
                bestAngle = testAngle
            }
        }
        
        debugLog("🔍 Optimal alignment: Best angle \(bestAngle) radians with \(bestOverlap * 100)% overlap", category: .geometry)
        return bestAngle
    }
    
    // MARK: - Private Helper Functions for Shape Matching
    
    /// Normalizes a shape to unit area while preserving proportions
    private static func normalizeShapeToUnitArea(_ vertices: [Vertex]) -> [Vertex] {
        let area = polygonArea(vertices: vertices)
        guard area > 1e-10 else { return vertices }
        
        let scaleFactor = 1.0 / sqrt(area)
        let centroid = polygonCentroid(vertices: vertices)
        
        return scaleVertices(vertices, from: centroid, by: scaleFactor)
    }
    
    /// Compares two normalized shapes with different vertex orderings
    private static func areNormalizedShapesEqual(_ vertices1: [Vertex], _ vertices2: [Vertex], 
                                               startOffset: Int, tolerance: Double) -> Bool {
        let count = vertices1.count
        
        for i in 0..<count {
            let idx1 = i
            let idx2 = (i + startOffset) % count
            
            let vertex1 = vertices1[idx1]
            let vertex2 = vertices2[idx2]
            
            let distance = sqrt(pow(vertex1.x - vertex2.x, 2) + pow(vertex1.y - vertex2.y, 2))
            if distance > tolerance {
                return false
            }
        }
        
        return true
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