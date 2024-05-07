Shader "Custom/SampleS"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {} 
        _BumpScale("Bump Scale", Range(0, 0.3)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma vertex vert
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        sampler2D _MainTex;
        float _BumpScale;

        void vert(inout appdata_full data, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldPos = mul(unity_ObjectToWorld, data.vertex);

            float value = tex2Dlod(_MainTex, float4(o.worldPos.x - floor(o.worldPos.x), o.worldPos.y - floor(o.worldPos.y), 0, 1));

            data.vertex = data.vertex + float4(data.normal * value * _BumpScale, 0);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = IN.worldPos.x - floor(IN.worldPos.x);
        }

        ENDCG
    }

    FallBack "Diffuse"
}
