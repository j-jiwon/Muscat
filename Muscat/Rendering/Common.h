//
//  Common.h
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/22.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

struct Uniforms {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
};

struct FragmentUniforms {
    vector_float3 cameraPosition;
};

#endif /* Common_h */
