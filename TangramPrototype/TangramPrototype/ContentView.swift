//
//  ContentView.swift
//  TangramPrototype
//
//  Created by yiran-gauntlet on 8/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🧩 Tangram Prototype")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Testing Implementation So Far...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Test Constants Display
            VStack(alignment: .leading, spacing: 8) {
                Text("📐 Geometric Constants:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Group {
                    Text("Base Unit: \(Constants.Geometry.baseUnit)pt")
                    Text("Vertex Tolerance: \(Constants.Geometry.vertexMatchTolerance)pt")
                    Text("Rotation Snap: \(String(format: "%.1f", Constants.Geometry.rotationSnapAngle * 180 / .pi))°")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text("🔧 Piece Dimensions:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                Group {
                    Text("Small Triangle: \(Constants.Geometry.smallTriangleLeg)pt")
                    Text("Large Triangle: \(Constants.Geometry.largeTriangleLeg)pt") 
                    Text("Medium Triangle: \(String(format: "%.1f", Constants.Geometry.mediumTriangleLeg))pt")
                    Text("Square Side: \(Constants.Geometry.squareSide)pt")
                    Text("Parallelogram: \(Constants.Geometry.parallelogramBase)×\(Constants.Geometry.parallelogramHeight)pt")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Visual Scale Test
            VStack {
                Text("📏 Visual Scale Test (baseUnit = 50pt):")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: Constants.Geometry.baseUnit, height: Constants.Geometry.baseUnit)
                        .overlay(Text("1×1\nunit").font(.caption).foregroundColor(.white))
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: Constants.Geometry.largeTriangleLeg, height: Constants.Geometry.baseUnit)
                        .overlay(Text("2×1\nunits").font(.caption).foregroundColor(.white))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Test debug logging
            Constants.Geometry.logGeometryConstants()
            debugLog("ContentView appeared - Constants test successful!", category: .ui)
        }
    }
}

#Preview {
    ContentView()
}
