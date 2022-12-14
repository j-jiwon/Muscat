//
//  Shaders.metal
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/06.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 color;
};

vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]]) {
    VertexOut out {
        .position = vertexBuffer.position,  // center (0, 0, 0)
        .color = float3(0, 0, 1),
    };
    out.position.y -= 0.5;
    return out;
}

fragment float4 fragment_main(VertexOut in  [[stage_in]]) {
    return float4(in.color, 1);  // color 전달 받아서 그려줌
}

