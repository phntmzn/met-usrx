import Foundation
import Metal
import MetalKit

class MetalRenderer {
    private var device: MTLDevice!
    private var pipeline: MTLComputePipelineState!
    private var commandQueue: MTLCommandQueue!

    init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device.makeCommandQueue()

        let libPath = Bundle.main.path(forResource: "default", ofType: "metallib")!
        let libData = try! Data(contentsOf: URL(fileURLWithPath: libPath))
        let library = try! device.makeLibrary(data: libData)
        let kernel = library.makeFunction(name: "audioPostProcess")!
        self.pipeline = try! device.makeComputePipelineState(function: kernel)
    }

    func applyEffect(input: [Float], effect: UInt32) -> [Float] {
        let count = input.count
        let inBuffer = device.makeBuffer(bytes: input, length: count * MemoryLayout<Float>.stride)!
        let outBuffer = device.makeBuffer(length: count * MemoryLayout<Float>.stride)!

        let effectBuffer = device.makeBuffer(bytes: [effect], length: 4)!
        let countBuffer = device.makeBuffer(bytes: [UInt32(count)], length: 4)!

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(pipeline)
        encoder.setBuffer(inBuffer, offset: 0, index: 0)
        encoder.setBuffer(outBuffer, offset: 0, index: 1)
        encoder.setBuffer(effectBuffer, offset: 0, index: 2)
        encoder.setBuffer(countBuffer, offset: 0, index: 3)

        let threadgroupSize = MTLSize(width: 256, height: 1, depth: 1)
        let threadgroupCount = MTLSize(width: (count + 255) / 256, height: 1, depth: 1)
        encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let outputPointer = outBuffer.contents().bindMemory(to: Float.self, capacity: count)
        return Array(UnsafeBufferPointer(start: outputPointer, count: count))
    }
}
