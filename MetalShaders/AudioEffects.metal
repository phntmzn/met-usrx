#include <metal_stdlib>
using namespace metal;

kernel void audioPostProcess(device float* inAudio  [[ buffer(0) ]],
                             device float* outAudio [[ buffer(1) ]],
                             constant uint& effectType [[ buffer(2) ]],
                             constant uint& sampleCount [[ buffer(3) ]],
                             uint id [[ thread_position_in_grid ]]) {
    if (id >= sampleCount) return;
    float input = inAudio[id];
    float output = 0.0;

    switch (effectType) {
        case 0: output = input; break;
        case 1: output = input * 0.5; break;
        case 2: output = clamp(input * 5.0, -1.0, 1.0); break;
        case 3: output = (id % 100 < 90) ? input : 0.0; break;
        case 4: output = -input; break;
        case 5: output = inAudio[id % 512]; break;
        default: output = input; break;
    }
    outAudio[id] = output;
}
