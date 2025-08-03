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

}
