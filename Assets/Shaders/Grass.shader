Shader "Custom/Grass"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _WindNoise("Wind Noise", 2D) = "blue" {}

        _TopTint("Top Tint", Color) = (1, 1, 1, 1)
        _BottomTint("Bottom Tint", Color) = (1, 1, 1, 1)

        _Metallicness("Metallicness", Float) = 1.0
        _Smoothness("Smoothness", Float) = 1.0

        _WindSpeed("Wind Speed", Float) = 1.0
        _MaxDisplacement("Max Displacement", Float) = 1.0

        _LookupCoords("Lookup Coords", Vector) = (1, 1, 1, 1)

        _Value("Value", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        // Allow Grass to render both sides of the mesh.    
        Cull Off

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vert
        #pragma multi_compile_instancing
        #pragma target 3.0

        sampler2D _MainTex, _WindNoise;

        float4 _TopTint, _BottomTint;

        float _Metallicness, _Smoothness;

        float _WindSpeed, _MaxDisplacement;
        
        float4 _LookupCoords;

        float _Value;

        struct Input
        {
            float2 uv_MainTex : TEXCOORD0;
            float3 worldPos : TEXCOORD1;
            float value : TEXCOORD2;
        };

        float looper(float2 coordinates)
        {
            coordinates.x -= floor(coordinates.x);
            coordinates.y -= floor(coordinates.y);

            float4 value = tex2Dlod(_WindNoise, float4(coordinates, 0, 1));

            return value.x;
        }

        void vert(inout appdata_full data, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldPos = mul(unity_ObjectToWorld, data.vertex);

            float3 mesh_world_pos = UNITY_MATRIX_M._m03_m13_m23;

            float2 lookupCoords = float2(mesh_world_pos.x + _Time.y * _WindSpeed, mesh_world_pos.z);
            float3 displacement = float3((looper(lookupCoords) * _MaxDisplacement - .5) * data.texcoord.y, 0, (looper(lookupCoords) * _MaxDisplacement - .5) * data.texcoord.y);
            displacement        = mul(float4(displacement, 1), unity_ObjectToWorld).xyz;

            data.vertex += float4(displacement, 0);
            o.value      = looper(lookupCoords);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = lerp(_BottomTint, _TopTint, IN.uv_MainTex.y);

            o.Metallic = _Metallicness;
            o.Smoothness = _Smoothness;
        }

        ENDCG
    }

    FallBack "Diffuse"
}
