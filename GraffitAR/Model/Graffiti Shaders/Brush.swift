//
//  VertBrush.swift
//
//

import Foundation
import SceneKit
import Firebase

let vertsPerPoint = 8
let maxPoints = 20000

extension SCNVector3: Codable {
    
    enum CodingKeys: CodingKey {
        case x
        case y
        case z
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.x = try container.decode(Float.self, forKey: .x)
        self.y = try container.decode(Float.self, forKey: .y)
        self.z = try container.decode(Float.self, forKey: .z)
    }
    
    
}

struct GraffitiObject: Codable {
    
    var vertices: [Vertex] = []
    
    let points: [SCNVector3]
    
    let indices: [UInt32]
    
    let lastVert: Int
    
    let lastIndex: Int
    
}

class VertBrush {
    
    // MARK: Metal
    
    var vertexBuffer: MTLBuffer! = nil
    var indexBuffer: MTLBuffer! = nil
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var previousSplitLine = false
    
    var bufferProvider: BufferProvider! = nil
    
    
    var vertices = [Vertex]()
    var points = [SCNVector3]()
    var indices = Array<UInt32>()
    
    var lastVertUpdateIdx = 0
    var lastIndexUpdateIdx = 0
    
    var prevPerpVec = SCNVector3Zero
    
    var light = Light(color: (0, 0, 1.0), ambientIntensity: 0,
                      direction: (0.0, 0.0, 1.0), diffuseIntensity: 1,
                      shininess: 10, specularIntensity: 0, time: 0.0)
    
    func addPoint( _ point : SCNVector3 , radius : Float = 0.01, splitLine : Bool = false ) {
        
        if points.count >= maxPoints {
            print("Max points reached")
            return
        }
        
        points.append(point)
        
        if points.count == 1 {
            return
        }
        
        if splitLine {
            previousSplitLine = true
            return
        }
        
        
        //let green = 0.5 + 0.5*sin( 0.1 * Float(points.count) )
        
        let pidx = points.count - 1
        
        let p1 = points[pidx]
        let p2 = points[pidx-1]
        
        let v1 = p1 - p2
        
        var v2 = SCNVector3Zero
        
        if SCNVector3EqualToVector3(prevPerpVec, SCNVector3Zero) {
            v2 = v1.cross(vector: SCNVector3(1.0, 1.0, 1.0)).normalized() * radius
        } else {
            v2 = SCNVector3ProjectPlane(vector: prevPerpVec, planeNormal: v1.normalized() ).normalized() * radius
        }
        
        prevPerpVec = v2
        
        // add p2 verts only if this is 2nd point
        if points.count == 2 || previousSplitLine {
            previousSplitLine = false
            
            for i in 0..<vertsPerPoint {
                let angle = (Float(i) / Float(vertsPerPoint)) * Float.pi * 2.0
                let v3 = SCNVector3Rotate(vector:v2, around:v1, radians:angle)
                vertices.append(toVert(p2 + v3, v3.normalized()))
            }
        }
        
        let idx_start = UInt32(vertices.count)
        
        // add current point's verts
        for i in 0..<vertsPerPoint {
            let angle = (Float(i) / Float(vertsPerPoint)) * Float.pi * 2.0
            let v3 = SCNVector3Rotate(vector:v2, around:v1, radians:angle)
            vertices.append(toVert(p1 + v3, v3.normalized()))
        }
        
        // add triangles
        
        let N : UInt32 = UInt32(vertsPerPoint)
        
        for i in 0..<vertsPerPoint {
            
            let idx: UInt32 = idx_start + UInt32(i)
            
            if i == vertsPerPoint-1 {
                indices.append( idx )
                indices.append( idx - N )
                indices.append( idx_start - N)
                
                indices.append( idx )
                indices.append( idx_start - N )
                indices.append( idx_start )
            } else {
                indices.append( idx )
                indices.append( idx - N )
                indices.append( idx - N + 1 )

                indices.append( idx )
                indices.append( idx - N + 1 )
                indices.append( idx + 1 )
            }
        }
        
        
    }
    
    func updateBuffers() {
        guard !vertices.isEmpty else { return }
        objc_sync_enter(self)
        updateIndexBuffer()
        updateVertexBuffer()
        objc_sync_exit(self)
    }
    
    func updateVertexBuffer() {
        let count = vertices.count
        let num = count - lastVertUpdateIdx
        let bufferPointer = vertexBuffer.contents()
        let dataSize = num * MemoryLayout<Vertex>.size
        let offset = lastVertUpdateIdx * MemoryLayout<Vertex>.size
        
        memcpy(bufferPointer + offset, &vertices+lastVertUpdateIdx, dataSize)
        lastVertUpdateIdx = count
    }
    
    func updateIndexBuffer() {
        let count = indices.count
        let num = count - lastIndexUpdateIdx
        let bufferPointer = indexBuffer.contents()
        let dataSize = num * 4
        let offset = 4 * lastIndexUpdateIdx
        memcpy(bufferPointer + offset, &indices+lastIndexUpdateIdx, dataSize)
        lastIndexUpdateIdx = count
    }

    func setPoints ( vert: [Vertex] = [Vertex](), pnts: [SCNVector3] = [SCNVector3](), idces: Array<UInt32> = Array<UInt32>(), lastVert: Int, lastIndex: Int)
    {
        self.clear()
        objc_sync_enter(self)
        vertices = vert
        points = pnts
        indices = idces
        lastVertUpdateIdx = lastVert
        lastIndexUpdateIdx = lastIndex
        objc_sync_exit(self)
        self.updateBuffers()
    }
    
    func getGraffitiPoints() -> GraffitiObject {
        return GraffitiObject(vertices: vertices,
                              points: points,
                              indices: indices,
                              lastVert: lastVertUpdateIdx,
                              lastIndex: lastIndexUpdateIdx)
    }
    
    func clear() {
        objc_sync_enter(self)
        vertices.removeAll()
        indices.removeAll()
        points.removeAll()
        lastVertUpdateIdx = 0
        lastIndexUpdateIdx = 0
        objc_sync_exit(self)
    }
    
    // Metal
    
    func render(_ commandQueue: MTLCommandQueue, _ renderEncoder: MTLRenderCommandEncoder, parentModelViewMatrix: float4x4, projectionMatrix: float4x4) {
        
        guard !indices.isEmpty else { return }
        objc_sync_enter(self)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix,
                                                              modelViewMatrix: parentModelViewMatrix,
                                                              light: light)
        
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: indices.count,
                                            indexType: MTLIndexType.uint32,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
        
        objc_sync_exit(self)
        
    }
    
    func setupPipeline(device : MTLDevice, pixelFormat : MTLPixelFormat ) {
        
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.depth32Float
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.add;
        pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.add;
        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.one;
        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.one;
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha;
        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha;
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        let vertDataSize = vertsPerPoint * maxPoints * MemoryLayout<Vertex>.size
        let indexDataSize = 3 * vertsPerPoint * maxPoints * MemoryLayout<Float>.size
        
        vertexBuffer = device.makeBuffer(length: vertDataSize, options: [])
        indexBuffer = device.makeBuffer(length: indexDataSize, options: [])
        
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3)
        
        
    }
    
    private func toVert(_ pp:SCNVector3, _ nn:SCNVector3 ) -> Vertex {
        return Vertex(x: pp.x, y: pp.y, z: pp.z,
                      r: 1.0, g: 0.5, b: 0.1, a: 1.0,
                      s: 0, t: 0,
                      nX: nn.x, nY: nn.y, nZ: nn.z)
    }
    
}
