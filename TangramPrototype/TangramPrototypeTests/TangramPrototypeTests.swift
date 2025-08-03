//
//  TangramPrototypeTests.swift
//  TangramPrototypeTests
//
//  Created by yiran-gauntlet on 8/2/25.
//

import Testing
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

}
