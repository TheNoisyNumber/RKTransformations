//
//  CubeState.swift
//  RKTransformations
//
//  Created by NoisyNumber on 3/18/24.
//

import Foundation
import UIKit
import RealityKit

class CubeState {
    var rotationX: Float = .zero
    var rotationY: Float = .zero
    var rotationZ: Float = .zero
    var velocityX: Float = .zero
    var velocityY: Float = .zero
    var panningState: UIGestureRecognizer.State = .possible
    var currentAxis: SIMD3<Float> = [1,0,0]
    var upVector: SIMD3<Float> = [0,1,0]
    var rightVector: SIMD3<Float> = [1,0,0]
    var quaternionRotation: simd_quatf = simd_quatf(angle: 0, axis: [1,0,0]) * simd_quatf(angle: 0, axis: [0,1,0]) * simd_quatf(angle: 0, axis: [0,0,1])
}
