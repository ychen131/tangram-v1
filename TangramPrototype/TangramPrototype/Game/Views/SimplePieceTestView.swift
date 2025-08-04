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
    @State private var selectedPieceIndex: Int? = nil
    @State private var showVertices = true
    @State private var dragStartPosition: CGPoint = .zero
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                controlsView
                testDisplayView
                debugInfoView
            }
            .padding()
        }
        .onAppear {
            setupTestPieces()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("🧩 Piece Model Test")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Testing geometric calculations and transformations")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var controlsView: some View {
        HStack {
            Button("Reset Pieces") {
                setupTestPieces()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Rotate All") {
                rotateAllPieces()
            }
            .buttonStyle(.borderedProminent)
            
            Toggle("Show Vertices", isOn: $showVertices)
                .toggleStyle(.button)
                .foregroundColor(showVertices ? .blue : .secondary)
        }
        .padding()
    }
    
    private var testDisplayView: some View {
        ZStack {
            backgroundView
            piecesView
        }
        .padding()
    }
    
    private var backgroundView: some View {
        Rectangle()
            .fill(Constants.Colors.UI.background)
            .frame(height: 400)
            .cornerRadius(12)
            .onTapGesture {
                selectedPieceIndex = nil
                debugLog("Deselected all pieces", category: .ui)
            }
    }
    
    private var piecesView: some View {
        ForEach(testPieces.indices, id: \.self) { index in
            pieceView(at: index)
        }
    }
    
    private func pieceView(at index: Int) -> some View {
        SimplePieceView(
            piece: testPieces[index],
            showVertices: showVertices,
            isSelected: selectedPieceIndex == index
        )
        .onTapGesture {
            selectedPieceIndex = index
            debugLog("Selected \(testPieces[index].type.displayName) piece", category: .ui)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if selectedPieceIndex != index {
                        // First touch - store the original position
                        selectedPieceIndex = index
                        dragStartPosition = testPieces[index].position
                    }
                    
                    // Calculate new position from original start position + translation
                    let newPosition = CGPoint(
                        x: dragStartPosition.x + value.translation.width,
                        y: dragStartPosition.y + value.translation.height
                    )
                    testPieces[index] = testPieces[index].moved(to: newPosition)
                    debugLog("Dragging \(testPieces[index].type.displayName) to (\(String(format: "%.1f", newPosition.x)), \(String(format: "%.1f", newPosition.y)))", category: .ui)
                }
                .onEnded { _ in
                    debugLog("Finished dragging \(testPieces[index].type.displayName)", category: .ui)
                }
        )
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
                        .fontWeight(.semibold)
                        .foregroundColor(piece.color)
                    
                    HStack {
                        Text("Position: (\(String(format: "%.1f", piece.position.x)), \(String(format: "%.1f", piece.position.y)))")
                        Spacer()
                        Text("Rotation: \(String(format: "%.2f", piece.rotation))°")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text("Vertices: \(piece.currentVertices.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(piece.color.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func setupTestPieces() {
        // Position pieces within the gray canvas area (400px height)
        // Canvas starts around y: 280 (after header + buttons), so center within that area
        let canvasTop: CGFloat = 300      // Starting Y of the gray canvas
        let canvasHeight: CGFloat = 400   // Height of gray canvas
        let centerX: CGFloat = 200        // Horizontal center of canvas
        let spacing: CGFloat = 100        // Spacing between pieces
        
        // Calculate Y positions within the canvas area
        let topRow = canvasTop + canvasHeight * 0.25     // 25% down in canvas
        let middleRow = canvasTop + canvasHeight * 0.5   // 50% down in canvas  
        let bottomRow = canvasTop + canvasHeight * 0.75  // 75% down in canvas
        
        testPieces = [
            // Row 1 - Top of canvas
            // Large Triangle 1 (red) - top left
            Piece(
                type: .largeTriangle1,
                position: CGPoint(x: centerX - spacing, y: topRow),
                rotation: 0,
                color: Constants.Colors.Pieces.largeTriangle1
            ),
            // Medium Triangle (green) - top center  
            Piece(
                type: .mediumTriangle,
                position: CGPoint(x: centerX, y: topRow),
                rotation: Double.pi / 2,
                color: Constants.Colors.Pieces.mediumTriangle
            ),
            // Large Triangle 2 (navy) - top right
            Piece(
                type: .largeTriangle2,
                position: CGPoint(x: centerX + spacing, y: topRow),
                rotation: Double.pi,
                color: Constants.Colors.Pieces.largeTriangle2
            ),
            
            // Row 2 - Middle of canvas
            // Small Triangle 1 (blue) - middle left
            Piece(
                type: .smallTriangle1,
                position: CGPoint(x: centerX - spacing, y: middleRow),
                rotation: Double.pi / 4,
                color: Constants.Colors.Pieces.smallTriangle1
            ),
            // Square (yellow) - center
            Piece(
                type: .square,
                position: CGPoint(x: centerX, y: middleRow),
                rotation: 0,
                color: Constants.Colors.Pieces.square
            ),
            // Small Triangle 2 (purple) - middle right
            Piece(
                type: .smallTriangle2,
                position: CGPoint(x: centerX + spacing, y: middleRow),
                rotation: Double.pi * 3/4,
                color: Constants.Colors.Pieces.smallTriangle2
            ),
            
            // Row 3 - Bottom of canvas
            // Parallelogram (orange) - bottom center
            Piece(
                type: .parallelogram,
                position: CGPoint(x: centerX, y: bottomRow),
                rotation: Double.pi / 6,
                color: Constants.Colors.Pieces.parallelogram
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
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Draw actual tangram shape using relative vertices
            relativeShape
                .fill(piece.color.opacity(0.6))
                .stroke(
                    isSelected ? Color.yellow : Constants.Colors.UI.strokeColor,
                    lineWidth: isSelected ? 4 : 2
                )
            
            // Text labels removed for cleaner visualization
            
            // Vertex visualization using relative positions
            if showVertices {
                ForEach(relativeVertices.indices, id: \.self) { index in
                    let vertex = relativeVertices[index]
                    Circle()
                        .fill(Constants.Colors.UI.vertexDot)
                        .frame(width: 10, height: 10)
                        .position(x: vertex.x, y: vertex.y)
                        .overlay(
                            Text("\(index)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .position(x: vertex.x, y: vertex.y)
                        )
                }
            }
        }
        .position(piece.position) // Position the entire view at the piece's center
    }
    
    // Convert absolute vertices to relative positions centered on the piece
    private var relativeVertices: [Vertex] {
        return piece.type.baseVertices.map { baseVertex in
            // Apply rotation around origin, but don't translate
            let rotatedX = baseVertex.x * cos(piece.rotation) - baseVertex.y * sin(piece.rotation)
            let rotatedY = baseVertex.x * sin(piece.rotation) + baseVertex.y * cos(piece.rotation)
            return Vertex(x: rotatedX, y: rotatedY)
        }
    }
    
    private var relativeShape: some Shape {
        TangramShape(vertices: relativeVertices)
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