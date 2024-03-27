//
//  ARCubeView.swift
//  RKTransformations
//
//  Created by Nick Ueda on 3/18/24.
//

import Foundation
import RealityKit
import UIKit
import Combine

class ARCubeView: ARView {
    var arView: ARView {return self}
    private var cubeUpdate: Cancellable?
    var cubeState = CubeState()
    var cubeEntity = Entity()

    @MainActor required dynamic override init(frame frameRect: CGRect, cameraMode: ARView.CameraMode, automaticallyConfigureSession: Bool) {
        cubeState.rotationX = 0
        cubeState.rotationY = 0
        super.init(frame: frameRect, cameraMode: cameraMode, automaticallyConfigureSession: automaticallyConfigureSession)
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    var rotationAngleX : Float = 0
    var rotationAngleY : Float = 0
    var rotationAngleZ : Float = 0
    func getSinglePlane(width: Float, depth: Float, color: UIColor, x:Float, y:Float, z:Float, rotationAngle:Float, rotationAxis:SIMD3<Float>) -> ModelEntity {
        let planeMesh = MeshResource.generatePlane(width: width, depth: depth)
        let planeMaterial = SimpleMaterial(color: color, roughness: 0.0, isMetallic: false)
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
        let planeRotation = simd_quatf(angle: rotationAngle, axis: rotationAxis)
        let planeTransform = Transform(scale:.one, rotation: planeRotation, translation: SIMD3<Float>(x,y,z))
        planeEntity.transform = planeTransform
        return planeEntity
    }
    
    func getCube() -> Entity {
        let cube = Entity()
        
        let frontFaceRed = UIColor(red: 226/255, green: 56/255, blue: 56/255, alpha: 1)
        let topFaceLime = UIColor(red: 94/255, green: 189/255, blue: 62/255, alpha: 1)//(94, 189, 62)
        let backFaceYellow : UIColor = .yellow //UIColor(red: 255/255, green: 185/255, blue: 0/255, alpha: 1)//(255, 185, 0)
        let bottomFaceOrange = UIColor(red: 247/255, green: 130/255, blue: 0/255, alpha: 1)//(247, 130, 0)
        let leftFacePurple = UIColor(red: 151/255, green: 57/255, blue: 153/255, alpha: 1) //(151, 57, 153)
        let rightFaceBlue = UIColor(red: 0/255, green: 156/255, blue: 223/255, alpha: 1) //(0, 156, 223)

        let frontFace = getSinglePlane(width: 5, depth: 5, color: frontFaceRed, x: 0, y: 0, z: 2.5, rotationAngle: Float(Double.pi / 2),rotationAxis: SIMD3<Float>(1,0,0))
        let bottomFace = getSinglePlane(width: 5, depth: 5, color: bottomFaceOrange, x: 0, y: -2.5, z: 0, rotationAngle: Float(Double.pi),rotationAxis: SIMD3<Float>(1,0,0))
        let topFace = getSinglePlane(width: 5, depth: 5, color: topFaceLime, x: 0, y: 2.5, z: 0, rotationAngle: 0,rotationAxis: SIMD3<Float>(0,1,0))
        let leftFace = getSinglePlane(width: 5, depth: 5, color: leftFacePurple, x: -2.5, y: 0, z: 0, rotationAngle: Float(Double.pi / 2),rotationAxis: SIMD3<Float>(0,0,1))
        let rightFace = getSinglePlane(width: 5, depth: 5, color: rightFaceBlue, x: 2.5, y: 0, z: 0, rotationAngle: -Float(Double.pi / 2),rotationAxis: SIMD3<Float>(0,0,1))
        let backFace = getSinglePlane(width: 5, depth: 5, color: backFaceYellow, x: 0, y: 0, z: -2.5, rotationAngle: -Float(Double.pi / 2),rotationAxis: SIMD3<Float>(1,0,0))
        
        cube.addChild(frontFace)
        cube.addChild(bottomFace)
        cube.addChild(topFace)
        cube.addChild(leftFace)
        cube.addChild(rightFace)
        cube.addChild(backFace)
        
        return cube
    }
    
    func getOriginAxes() -> Entity {
        let mesh = MeshResource.generateBox(width: 50, height: 0.1, depth: 0.1)
        let meshY = MeshResource.generateBox(width: 50, height: 0.1, depth: 0.1)
        let materialRed = SimpleMaterial(color: .red, roughness: 0, isMetallic: true)
        let materialGreen = SimpleMaterial(color: .green, roughness: 0, isMetallic: true)
        let materialBlue = SimpleMaterial(color: .blue, roughness: 0, isMetallic: true)
        let xAxis = ModelEntity(mesh: mesh, materials: [materialRed])
        let yAxis = ModelEntity(mesh: meshY, materials: [materialGreen])

        let yRotation = simd_quatf(angle: Float(Double.pi / 2), axis: SIMD3<Float>(0,0,1))
        yAxis.transform = Transform(scale: .one, rotation: yRotation, translation: SIMD3<Float>(0,0,0))
        
        let zAxis = ModelEntity(mesh: mesh, materials: [materialBlue])
        let zRotation = simd_quatf(angle: Float(Double.pi / 2), axis: SIMD3<Float>(0,1,0))
        
        zAxis.transform = Transform(scale: .one, rotation: zRotation, translation: SIMD3<Float>(0,0,0))
        let axesEntity = Entity()
        axesEntity.addChild(xAxis)
        axesEntity.addChild(yAxis)
        axesEntity.addChild(zAxis)
        return axesEntity
    }

    func whatIsUp(orientation:simd_quatf) -> SIMD3<Float> {
        // Define local axes of the entity
        let xAxis = SIMD3<Float>(1, 0, 0)
        let yAxis = SIMD3<Float>(0, 1, 0)
        let zAxis = SIMD3<Float>(0, 0, 1)

        // Apply quaternion rotations to the entity (rotationQuaternion represents the combined rotations)
        let rotatedXAxis = orientation.act(xAxis)
        let rotatedYAxis = orientation.act(yAxis)
        let rotatedZAxis = orientation.act(zAxis)

        // Normalize the transformed vectors
        let normalizedRotatedXAxis = simd_normalize(rotatedXAxis)
        let normalizedRotatedYAxis = simd_normalize(rotatedYAxis)
        let normalizedRotatedZAxis = simd_normalize(rotatedZAxis)

        // Determine which local vector is pointing up in the world's coordinate system
        if abs(round(normalizedRotatedXAxis.y)) == 1 {
            return SIMD3<Float>(round(normalizedRotatedXAxis.y), 0, 0)
        }
        else if abs(round(normalizedRotatedYAxis.y)) == 1 {
            return SIMD3<Float>(0, round(normalizedRotatedYAxis.y), 0)
        }
        else {//if abs(round(normalizedRotatedZAxis.y)) == 1{
            return SIMD3<Float>(0, 0, round(normalizedRotatedZAxis.y))
        }
    }
    
    func whatIsRight(orientation:simd_quatf) -> SIMD3<Float> {
        // Define local axes of the entity
        let xAxis = SIMD3<Float>(1, 0, 0)
        let yAxis = SIMD3<Float>(0, 1, 0)
        let zAxis = SIMD3<Float>(0, 0, 1)

        // Apply quaternion rotations to the entity (rotationQuaternion represents the combined rotations)
        let rotatedXAxis = orientation.act(xAxis)
        let rotatedYAxis = orientation.act(yAxis)
        let rotatedZAxis = orientation.act(zAxis)

        // Normalize the transformed vectors
        let normalizedRotatedXAxis = simd_normalize(rotatedXAxis)
        let normalizedRotatedYAxis = simd_normalize(rotatedYAxis)
        let normalizedRotatedZAxis = simd_normalize(rotatedZAxis)
        
        // Determine which local vector is pointing up in the world's coordinate system
        //print("\(normalizedRotatedXAxis.x),\(normalizedRotatedYAxis.x),\(normalizedRotatedZAxis.x)")
        if abs(round(normalizedRotatedXAxis.x)) == 1 {
            return SIMD3<Float>(round(normalizedRotatedXAxis.x), 0, 0)
        }
        else if abs(round(normalizedRotatedYAxis.x)) == 1 {
            return SIMD3<Float>(0, round(normalizedRotatedYAxis.x), 0)
        }
        else {
            return SIMD3<Float>(0, 0, round(normalizedRotatedZAxis.x))
        }
    }

    var nearestIncrementPrinted = false
    func setup(){
        let sceneAnchor = AnchorEntity(world: [0,0,0])
        let sceneEntity = Entity()

        let cubeEntity = getCube()
        let axes = getOriginAxes()
        sceneEntity.addChild(cubeEntity)
        sceneEntity.addChild(axes)
        sceneAnchor.addChild(sceneEntity)
        arView.scene.addAnchor(sceneAnchor)

        let camera = PerspectiveCamera()
        let cameraAnchor = AnchorEntity(world:[0,0,0])
        camera.look(at: SIMD3<Float>(x: 0, y: 0, z: 0), from: SIMD3<Float>(x: -10, y: 10, z: 15), relativeTo: nil)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        arView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))

        self.cubeUpdate = scene.subscribe(to: SceneEvents.Update.self) { event in
            sceneEntity.transform.rotation = self.cubeState.quaternionRotation

            if self.cubeState.panningState == .ended {
                //Simply put when panning ends we want to start gravitating toward the nearest 90 degree increment
                var xAngleInDegrees = self.cubeState.rotationX * Float(180/Double.pi)
                var yAngleInDegrees = self.cubeState.rotationY * Float(180/Double.pi)
                let x1 = xAngleInDegrees / Float(90)
                let nearest_x_increment_in_degrees : Float = round(x1) * Float(90)
                
                let y1 = yAngleInDegrees / Float(90)
                let nearest_y_increment_in_degrees : Float = round(y1) * Float(90)

//                if !self.nearestIncrementPrinted {
//                    print("nearest_increment: \(nearest_increment_in_degrees)")
//                    print("xAngleInDegrees: \(xAngleInDegrees)")
//                    print("distance to nearest increment: \(nearest_increment_in_degrees - xAngleInDegrees)")
//                    print("self.cubeState.rotationX: \(self.cubeState.rotationX)")
//                }

                if round(abs(xAngleInDegrees)) > 1 {
                    // We want to know the distance between the nearest increment of 90 degrees and whatever the current angle is
                    
                    // We get 10% of that so that the amount of change decreases over time.
                    let xDelta = (nearest_x_increment_in_degrees - xAngleInDegrees) * 0.15
                    
                    // We want to take whatever the current xAngle is in degrees and then add the delta to it.
                    xAngleInDegrees = round(xAngleInDegrees) + xDelta
                    
                    //We want to add the current delta to rotationX in radians
                    self.cubeState.rotationX += xDelta * Float(Double.pi / 180)

                    //We only want to rotate our quaternion by the delta here (in radians).
                    self.cubeState.quaternionRotation *= simd_quatf(angle: xDelta * Float(Double.pi / 180), axis: self.cubeState.upVector)
                    
                    //This code works, change is a constant 1 though
//                    xAngleInDegrees = round(xAngleInDegrees) - 1
//                    self.cubeState.rotationX += -1 * Float(Double.pi / 180)
//print("xAngleInDegrees: \(round(xAngleInDegrees))")
//                    self.cubeState.quaternionRotation *= simd_quatf(angle: -1 * Float(Double.pi / 180), axis: self.cubeState.upVector)
                }

                if round(abs(yAngleInDegrees)) > 1 {
                    let yDelta = (nearest_y_increment_in_degrees - yAngleInDegrees) * 0.15
                    yAngleInDegrees = round(yAngleInDegrees) + yDelta
                    self.cubeState.rotationY += yDelta * Float(Double.pi / 180)
                    self.cubeState.quaternionRotation *= simd_quatf(angle: yDelta * Float(Double.pi / 180), axis: self.cubeState.rightVector)
                }
                
                //self.nearestIncrementPrinted = true
            }
            
        }
    }

    @objc func handlePan(sender:UIPanGestureRecognizer){
        let v = sender.velocity(in: arView)
        let t = sender.translation(in: arView)
        //self.nearestIncrementPrinted = false
        if abs(t.x) > abs(t.y) {
            self.cubeState.velocityX = Float(v.x) * 0.0001
            self.cubeState.rotationX += Float(v.x) * 0.0001
            self.cubeState.quaternionRotation *= simd_quatf(angle: self.cubeState.velocityX, axis: self.cubeState.upVector)
        }
        else {
            self.cubeState.velocityY = Float(v.y) * 0.0001
            self.cubeState.rotationY += Float(v.y) * 0.0001
            self.cubeState.quaternionRotation *= simd_quatf(angle: self.cubeState.velocityY, axis: self.cubeState.rightVector)
        }

        self.cubeState.upVector = whatIsUp(orientation: self.cubeState.quaternionRotation)
        self.cubeState.rightVector = whatIsRight(orientation: self.cubeState.quaternionRotation)        
        self.cubeState.panningState = sender.state
    }
}

