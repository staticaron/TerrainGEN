Shader "Custom/m_Terrain"
{
    Properties
    {
        _ColorMap ("Albedo", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _ColorMap;

        struct Input
        {
            float2 uv_ColorMap;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 c = tex2D(_ColorMap, IN.uv_ColorMap);
            o.Albedo = c.rgb;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
