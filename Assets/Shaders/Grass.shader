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

        struct Input
        {
            float2 uv_MainTex : TEXCOORD0;
        };

        float looper(float2 coordinates)
        {
            coordinates.x -= floor(coordinates.x);
            coordinates.y -= floor(coordinates.y);

            float4 value = tex2Dlod(_WindNoise, float4(coordinates, 0, 1));

            return value.x;
        }

        void vert(inout appdata_full data)
        {
            float2 lookupCoords = float2(0.5 + _Time.y * _WindSpeed, 0.5);
            float displacement = (looper(lookupCoords) * _MaxDisplacement - .5)* data.texcoord.y ;
            
            float3 worldVert = mul((float3x3) unity_ObjectToWorld, data.vertex.xyz);
            worldVert.x += displacement;

            data.vertex = mul(unity_WorldToObject, worldVert);;
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
