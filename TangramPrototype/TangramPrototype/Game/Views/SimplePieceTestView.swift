//
//  SimplePieceTestView.swift
//  TangramPrototype
//
//  Created by AI Assistant on 8/3/25.
//  Purpose: Simple test interface for Piece model validation
//

import SwiftUI

/// Simple test view for validating Piece model functionality
struct SimplePieceTestView: View {
    
    @State private var testPieces: [Piece] = []
    @State private var showVertices = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("🧩 Piece Model Test")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Testing geometric calculations and transformations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Controls
                HStack {
                    Button("Reset Pieces") {
                        setupTestPieces()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Toggle Vertices") {
                        showVertices.toggle()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Rotate All") {
                        rotateAllPieces()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                // Test display area
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 400)
                        .cornerRadius(12)
                    
                    // Display pieces
                    ForEach(testPieces.indices, id: \.self) { index in
                        SimplePieceView(
                            piece: testPieces[index],
                            showVertices: showVertices
                        )
                    }
                }
                .padding()
                
                // Debug information
                debugInfoView
            }
            .padding()
        }
        .onAppear {
            setupTestPieces()
        }
    }
    
    private var debugInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🐛 Debug Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(testPieces.indices, id: \.self) { index in
                let piece = testPieces[index]
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(piece.type.displayName)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(piece.color)
                    
                    Text("Position: (\(String(format: "%.0f", piece.position.x)), \(String(format: "%.0f", piece.position.y)))")
                        .font(.caption)
                    
                    Text("Rotation: \(String(format: "%.1f", piece.rotation * 180 / Double.pi))°")
                        .font(.caption)
                    
                    Text("Vertices: \(piece.currentVertices.count)")
                        .font(.caption)
                    
                    if !piece.currentVertices.isEmpty {
                        Text("First vertex: (\(String(format: "%.1f", piece.currentVertices[0].x)), \(String(format: "%.1f", piece.currentVertices[0].y)))")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func setupTestPieces() {
        testPieces = [
            // Large Triangle (2×2 legs) - no rotation to see base shape clearly
            Piece(
                type: .largeTriangle1,
                position: CGPoint(x: 120, y: 120),
                rotation: 0,
                color: .red
            ),
            // Small Triangle (1×1 legs) - rotated 45° 
            Piece(
                type: .smallTriangle1,
                position: CGPoint(x: 280, y: 120),
                rotation: Double.pi / 4,
                color: .blue
            ),
            // Square (1×1 sides) - displayed as diamond, no additional rotation
            Piece(
                type: .square,
                position: CGPoint(x: 120, y: 220),
                rotation: 0,
                color: .green
            ),
            // Medium Triangle (√2×√2 legs) - rotated 90°
            Piece(
                type: .mediumTriangle,
                position: CGPoint(x: 280, y: 220),
                rotation: Double.pi / 2,
                color: .purple
            ),
            // Parallelogram (base=2, height=1) - rotated 30°
            Piece(
                type: .parallelogram,
                position: CGPoint(x: 200, y: 320),
                rotation: Double.pi / 6,
                color: .orange
            )
        ]
        
        debugLog("Created \(testPieces.count) test pieces with corrected tangram shapes", category: .debug)
    }
    
    private func rotateAllPieces() {
        for index in testPieces.indices {
            let newRotation = testPieces[index].rotation + Double.pi / 8
            testPieces[index] = testPieces[index].rotated(to: newRotation)
        }
        debugLog("Rotated all pieces by 22.5 degrees", category: .debug)
    }
}

// Accurate tangram piece rendering using actual vertex coordinates
struct SimplePieceView: View {
    let piece: Piece
    let showVertices: Bool
    
    var body: some View {
        ZStack {
            // Draw actual tangram shape using current vertices
            actualTangramShape
                .fill(piece.color.opacity(0.6))
                .stroke(Color.black, lineWidth: 2)
            
            // Show piece type label
            Text(piece.type.displayName)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
                .position(piece.centerPosition)
            
            // Vertex visualization - these should now align perfectly with shape corners
            if showVertices {
                ForEach(piece.currentVertices.indices, id: \.self) { index in
                    let vertex = piece.currentVertices[index]
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .position(x: vertex.x, y: vertex.y)
                        .overlay(
                            Text("\(index)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
    
    // Draw the actual tangram shape using transformed vertices
    private var actualTangramShape: some Shape {
        TangramShape(vertices: piece.currentVertices)
    }
}

// Custom Shape that draws a polygon from vertex coordinates
struct TangramShape: Shape {
    let vertices: [Vertex]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !vertices.isEmpty else { return path }
        
        // Move to first vertex
        let firstVertex = vertices[0]
        path.move(to: CGPoint(x: firstVertex.x, y: firstVertex.y))
        
        // Draw lines to all other vertices
        for vertex in vertices.dropFirst() {
            path.addLine(to: CGPoint(x: vertex.x, y: vertex.y))
        }
        
        // Close the path back to first vertex
        path.closeSubpath()
        
        return path
    }
}

struct SimplePieceTestView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePieceTestView()
    }
}