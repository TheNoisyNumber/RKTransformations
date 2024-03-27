//
//  ContentView.swift
//  RKTransformations
//
//  Created by NoisyNumber on 3/18/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var cubeState = CubeState()
    var body: some View {
        ARViewContainer(cubeState).edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    private var cubeState: CubeState

    public init(_ cubeState: CubeState){
        self.cubeState = cubeState
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARCubeView(frame: .zero, cameraMode: ARView.CameraMode.nonAR, automaticallyConfigureSession: false)
        arView.setup()
        arView.cubeState = cubeState
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
    
}

#Preview {
    ContentView()
}
