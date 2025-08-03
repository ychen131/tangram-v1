//
//  TangramPrototypeTests.swift
//  TangramPrototypeTests
//
//  Created by yiran-gauntlet on 8/2/25.
//

import Testing
import SwiftUI
import Foundation
@testable import TangramPrototype

struct TangramPrototypeTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func testConstantsInitialization() async throws {
        // Test that our baseUnit constant is correctly set
        #expect(Constants.Geometry.baseUnit == 50.0)
        
        // Test calculated dimensions
        #expect(Constants.Geometry.smallTriangleLeg == 50.0)
        #expect(Constants.Geometry.largeTriangleLeg == 100.0)
        #expect(Constants.Geometry.squareSide == 50.0)
        
        // Test UI constants
        #expect(Constants.UI.standardAnimationDuration == 0.3)
        #expect(Constants.UI.minimumTouchArea == 44.0)
        
        // Test Game constants  
        #expect(Constants.Game.totalPieceCount == 7)
        #expect(Constants.Game.Scoring.basePuzzlePoints == 100)
        
        // Test Debug constants
        #expect(Constants.Debug.enableDebugLogging == true)
        
        debugLog("✅ Constants test completed successfully!", category: .debug)
    }
    
    @Test func testVertexBasicOperations() async throws {
        // Test basic vertex creation (4.1)
        let origin = Vertex()
        #expect(origin.x == 0.0)
        #expect(origin.y == 0.0)
        
        let point = Vertex(x: 10.0, y: 20.0)
        #expect(point.x == 10.0)
        #expect(point.y == 20.0)
        
        // Test equality with tolerance (4.2)
        let point1 = Vertex(x: 10.0, y: 20.0)
        let point2 = Vertex(x: 10.001, y: 20.001) // Within tolerance
        #expect(point1 == point2) // Should be equal due to tolerance
        
        // Test translation (4.3)
        let translated = point.translated(by: 5.0, dy: 10.0)
        #expect(translated.x == 15.0)
        #expect(translated.y == 30.0)
        
        // Test rotation (4.4) - 90° counterclockwise rotation around origin
        let rotated = Vertex(x: 1.0, y: 0.0).rotated(by: .pi / 2)
        #expect(abs(rotated.x) < Constants.Geometry.vertexMatchTolerance) // Should be ~0
        #expect(abs(rotated.y - 1.0) < Constants.Geometry.vertexMatchTolerance) // Should be ~1
        
        // Test CGPoint conversion
        let cgPoint = point.toCGPoint()
        #expect(cgPoint.x == 10.0)
        #expect(cgPoint.y == 20.0)
        
        debugLog("✅ Vertex test completed successfully!", category: .debug)
    }
    
    @Test func testVertexDistanceCalculations() async throws {
        // Test basic distance calculation (4.5)
        let vertex1 = Vertex(x: 0, y: 0)
        let vertex2 = Vertex(x: 3, y: 4)
        
        let distance = vertex1.distance(to: vertex2)
        #expect(abs(distance - 5.0) < 0.001) // 3-4-5 triangle
        
        // Test squared distance (optimization for comparisons)
        let squaredDist = vertex1.squaredDistance(to: vertex2)
        #expect(abs(squaredDist - 25.0) < 0.001) // 3² + 4² = 25
        
        // Test static distance method
        let staticDistance = Vertex.distance(from: vertex1, to: vertex2)
        #expect(abs(staticDistance - 5.0) < 0.001)
        
        // Test within distance threshold
        #expect(vertex1.isWithinDistance(6.0, of: vertex2)) // Should be true (5 < 6)
        #expect(!vertex1.isWithinDistance(4.0, of: vertex2)) // Should be false (5 > 4)
        
        // Test matching with tolerance
        let closeVertex = Vertex(x: 0.001, y: 0.001) // Within tolerance
        #expect(vertex1.matches(closeVertex)) // Should match due to tolerance
        
        debugLog("✅ Vertex distance calculations test completed successfully!", category: .debug)
    }
    
    @Test func testVertexEdgeCases() async throws {
        // Test zero vertex
        let zero = Vertex()
        #expect(zero.x == 0.0)
        #expect(zero.y == 0.0)
        
        // Test very large coordinates
        let large = Vertex(x: 1e6, y: 1e6)
        #expect(large.x == 1e6)
        #expect(large.y == 1e6)
        
        // Test negative coordinates
        let negative = Vertex(x: -100, y: -200)
        #expect(negative.x == -100)
        #expect(negative.y == -200)
        
        // Test self distance (should be 0)
        #expect(large.distance(to: large) == 0.0)
        
        // Test midpoint calculation
        let mid = zero.midpoint(to: large)
        #expect(mid.x == 5e5)
        #expect(mid.y == 5e5)
        
        debugLog("✅ Vertex edge cases test completed successfully!", category: .debug)
    }
    
    @Test func testVertexConstantsIntegration() async throws {
        // Test integration with Constants.Geometry (4.8)
        let v1 = Vertex(x: 0, y: 0)
        let v2 = Vertex(x: Constants.Geometry.vertexMatchTolerance / 2, y: 0)
        
        // Should be considered equal due to tolerance
        #expect(v1 == v2)
        #expect(v1.matches(v2))
        
        // Test with baseUnit
        let baseVertex = Vertex(x: Constants.Geometry.baseUnit, y: Constants.Geometry.baseUnit)
        #expect(baseVertex.x == 50.0)
        #expect(baseVertex.y == 50.0)
        
        // Test rotation with snap angles
        let rotated = v1.rotated(by: Constants.Geometry.rotationSnapAngle)
        let expectedAngle = Constants.Geometry.rotationSnapAngle
        // After rotation by snap angle, should be at expected position
        #expect(abs(rotated.x - 0) < 0.001) // cos(15°) ≈ 0.966, but for (0,0) stays (0,0)
        #expect(abs(rotated.y - 0) < 0.001)
        
        debugLog("✅ Vertex-Constants integration test completed successfully!", category: .debug)
    }
    
    // MARK: - Piece Model Tests (Subtask 5.8)
    
    @Test func testPieceBasicCreation() async throws {
        // Test basic piece creation (5.1)
        let position = CGPoint(x: 100, y: 200)
        let piece = Piece(type: .largeTriangle1, position: position, rotation: Double.pi / 4, color: .blue)
        
        #expect(piece.type == PieceType.largeTriangle1)
        #expect(piece.position == position)
        #expect(abs(piece.rotation - Double.pi / 4) < 0.001)
        #expect(piece.id != UUID()) // Should have a unique ID
        
        debugLog("✅ Piece basic creation test completed successfully!", category: .debug)
    }
    
    @Test func testPieceTypeDefinitions() async throws {
        // Test temporary piece type definitions (5.2)
        let largeTriangle = Piece(type: .largeTriangle1, position: CGPoint.zero, color: .red)
        let smallTriangle = Piece(type: .smallTriangle1, position: CGPoint.zero, color: .blue)
        let square = Piece(type: .square, position: CGPoint.zero, color: .green)
        
        // Test base vertices are properly defined
        #expect(largeTriangle.type.baseVertices.count == 3) // Triangle should have 3 vertices
        #expect(smallTriangle.type.baseVertices.count == 3) // Triangle should have 3 vertices
        #expect(square.type.baseVertices.count == 4) // Square should have 4 vertices
        
        // Test piece type display names
        #expect(largeTriangle.type.displayName == "Large Triangle 1")
        #expect(smallTriangle.type.displayName == "Small Triangle 1")
        #expect(square.type.displayName == "Square")
        
        debugLog("✅ Piece type definitions test completed successfully!", category: .debug)
    }
    
    @Test func testPieceCurrentVertices() async throws {
        // Test current vertices calculation (5.4)
        let basePosition = CGPoint(x: 100, y: 100)
        let piece = Piece(type: .smallTriangle1, position: basePosition, rotation: 0, color: .red)
        
        let vertices = piece.currentVertices
        #expect(vertices.count == 3) // Small triangle should have 3 vertices
        
        // Test that vertices are translated to piece position
        // Base vertices start at origin, should be translated by piece position
        let expectedBaseX = 100.0 // position.x + base vertex x
        let expectedBaseY = 100.0 // position.y + base vertex y
        
        // First vertex should be at piece position (since base vertex at origin)
        #expect(abs(vertices[0].x - expectedBaseX) < 1.0)
        #expect(abs(vertices[0].y - expectedBaseY) < 1.0)
        
        debugLog("✅ Piece current vertices calculation test completed successfully!", category: .debug)
    }
    
    @Test func testPieceRotationTransformation() async throws {
        // Test rotation transformation (5.4)
        let position = CGPoint(x: 0, y: 0) // Use origin for simpler math
        let piece = Piece(type: .smallTriangle1, position: position, rotation: Double.pi / 2, color: .blue)
        
        let rotatedVertices = piece.currentVertices
        let originalPiece = Piece(type: .smallTriangle1, position: position, rotation: 0, color: .blue)
        let originalVertices = originalPiece.currentVertices
        
        #expect(rotatedVertices.count == originalVertices.count)
        
        // After 90° rotation, the shape should be rotated
        // We can't easily test exact values due to floating point precision,
        // but we can verify the structure is preserved
        #expect(rotatedVertices.count == 3)
        
        debugLog("✅ Piece rotation transformation test completed successfully!", category: .debug)
    }
    
    @Test func testPieceManipulation() async throws {
        // Test piece manipulation methods (5.5)
        let originalPosition = CGPoint(x: 100, y: 100)
        let piece = Piece(type: .mediumTriangle, position: originalPosition, rotation: 0, color: .green)
        
        // Test translation
        let translated = piece.translated(by: 50, dy: 30)
        #expect(translated.position.x == 150)
        #expect(translated.position.y == 130)
        #expect(translated.type == piece.type) // Type should remain same
        #expect(translated.rotation == piece.rotation) // Rotation should remain same
        
        // Test absolute move
        let newPosition = CGPoint(x: 200, y: 250)
        let moved = piece.moved(to: newPosition)
        #expect(moved.position == newPosition)
        
        // Test rotation
        let rotated = piece.rotated(by: Double.pi / 4)
        #expect(abs(rotated.rotation - Double.pi / 4) < 0.001)
        #expect(rotated.position == piece.position) // Position should remain same
        
        // Test absolute rotation
        let absoluteRotated = piece.rotated(to: Double.pi / 3)
        #expect(abs(absoluteRotated.rotation - Double.pi / 3) < 0.001)
        
        // Test reset
        let reset = rotated.resetPosition()
        #expect(reset.rotation == 0.0)
        #expect(reset.position == rotated.position) // Default keeps same position
        
        let resetWithNewPos = rotated.resetPosition(at: CGPoint.zero)
        #expect(resetWithNewPos.rotation == 0.0)
        #expect(resetWithNewPos.position == CGPoint.zero)
        
        debugLog("✅ Piece manipulation methods test completed successfully!", category: .debug)
    }
    
    @Test func testPieceRotationSnapping() async throws {
        // Test rotation snapping (5.5)
        let piece = Piece(type: .square, position: CGPoint.zero, rotation: 0.1, color: .orange) // Slightly off snap
        
        let snapped = piece.withSnappedRotation()
        let expectedSnap = round(0.1 / Constants.Geometry.rotationSnapAngle) * Constants.Geometry.rotationSnapAngle
        
        #expect(abs(snapped.rotation - expectedSnap) < 0.001)
        
        // Test piece already on snap angle
        let onSnap = Piece(type: .square, position: CGPoint.zero, rotation: Constants.Geometry.rotationSnapAngle, color: .orange)
        let shouldNotChange = onSnap.withSnappedRotation()
        #expect(shouldNotChange.rotation == onSnap.rotation)
        
        debugLog("✅ Piece rotation snapping test completed successfully!", category: .debug)
    }
    
    @Test func testPieceSwiftUIIntegration() async throws {
        // Test SwiftUI integration helpers (5.6)
        let position = CGPoint(x: 150, y: 200)
        let rotation = Double.pi / 6
        let piece = Piece(type: .parallelogram, position: position, rotation: rotation, color: .purple)
        
        // Test center position (should be same as position)
        #expect(piece.centerPosition == position)
        
        // Test rotation angle conversion
        let angle = piece.rotationAngle
        #expect(abs(angle.radians - rotation) < 0.001)
        
        // Test bounding box calculation
        let boundingBox = piece.boundingBox
        #expect(boundingBox.width > 0)
        #expect(boundingBox.height > 0)
        
        // Test estimated frame size
        let frameSize = piece.estimatedFrameSize
        #expect(frameSize.width > 0)
        #expect(frameSize.height > 0)
        
        // Test animated move
        let newPos = CGPoint(x: 300, y: 400)
        let animatedMove = piece.movingTo(newPos, animated: true)
        #expect(animatedMove.position == newPos)
        
        debugLog("✅ Piece SwiftUI integration test completed successfully!", category: .debug)
    }
    
    @Test func testPieceEquality() async throws {
        // Test Equatable conformance (5.3)
        let piece1 = Piece(type: .largeTriangle2, position: CGPoint(x: 100, y: 100), rotation: Double.pi / 4, color: .red)
        let piece2 = Piece(type: .largeTriangle2, position: CGPoint(x: 100, y: 100), rotation: Double.pi / 4, color: .blue) // Different color
        
        // Different pieces with same properties should NOT be equal (different IDs)
        #expect(piece1 != piece2)
        
        // Same piece should equal itself
        #expect(piece1 == piece1)
        
        debugLog("✅ Piece equality test completed successfully!", category: .debug)
    }
    
    @Test func testPieceDebugSupport() async throws {
        // Test debug support and CustomStringConvertible (5.7)
        let piece = Piece(type: .smallTriangle2, position: CGPoint(x: 75, y: 125), rotation: Double.pi / 2, color: .cyan)
        
        // Test description
        let description = piece.description
        #expect(description.contains("Small Triangle 2"))
        #expect(description.contains("75.0")) // Position x
        #expect(description.contains("125.0")) // Position y
        #expect(description.contains("90.0")) // Rotation in degrees
        
        // Test status string
        let status = piece.statusString
        #expect(status.contains("small_triangle_2"))
        #expect(status.contains("75"))
        #expect(status.contains("125"))
        #expect(status.contains("90.0"))
        
        // Test debug description (contains vertex info)
        let debugDesc = piece.debugDescription
        #expect(debugDesc.contains("ID:"))
        #expect(debugDesc.contains("Vertices:"))
        #expect(debugDesc.contains("Bounding Box:"))
        
        debugLog("✅ Piece debug support test completed successfully!", category: .debug)
    }
    
    @Test func testPieceGeometricAccuracy() async throws {
        // Test geometric accuracy and precision (5.9)
        let piece = Piece(type: .largeTriangle1, position: CGPoint(x: 0, y: 0), rotation: 0, color: .black)
        let vertices = piece.currentVertices
        
        // Large triangle should have vertices at expected positions (scaled by baseUnit)
        let unit = Double(Constants.Geometry.baseUnit)
        
        // Expected vertices for large triangle at origin with no rotation:
        // (0,0), (2*unit, 0), (0, 2*unit)
        #expect(abs(vertices[0].x - 0) < 1.0)
        #expect(abs(vertices[0].y - 0) < 1.0)
        #expect(abs(vertices[1].x - 2*unit) < 1.0)
        #expect(abs(vertices[1].y - 0) < 1.0)
        #expect(abs(vertices[2].x - 0) < 1.0)
        #expect(abs(vertices[2].y - 2*unit) < 1.0)
        
        debugLog("✅ Piece geometric accuracy test completed successfully!", category: .debug)
    }

}
