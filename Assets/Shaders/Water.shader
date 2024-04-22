Shader "Custom/Water"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_WaveNoise("Wave Noise", 2D) = "white" {}
		_MaxAmplitude("Max Amplitude", Float) = 1.0

		_WaveNormal1("Wave Normal 1", 2D) = "blue" {}
		_WaveNormal2("Wave Normal 2", 2D) = "blue" {}

		_NormalIntensity1("Normal Intensity 1", Range(0, 1)) = 1.0
		_NormalIntensity2("Normal Intensity 2", Range(0, 1)) = 1.0

		_WaterHighlightTint("Water Highlight Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_WaterBaseTint("Water Base Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_WaterAlpha("Water Alpha", Range(0, 1)) = 0.5

		_WaveSpeed("Wave Speed", Float) = 1.0

		_Smoothness("Smoothness", Range(0, 1)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade
		#pragma target 3.0

		sampler2D _WaveTexture;

		sampler2D _WaveNoise;
		float4 _WaveNoise_ST;

		float _MaxAmplitude;

		sampler2D _WaveNormal1;
		sampler2D _WaveNormal2;

		float _NormalIntensity1;
		float _NormalIntensity2;

		float4 _WaterHighlightTint;
		float4 _WaterBaseTint;
		float _WaterAlpha;

		float _WaveSpeed;

		float _Smoothness;


		sampler2D _CameraDepthTexture;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_WaveNoise;
		};

		void vert(inout appdata_full data)
		{
			float2 wave_noise_coords = data.texcoord;
			wave_noise_coords.xy += _WaveSpeed * _Time.y;

			float2 waveNoiseUV = TRANSFORM_TEX(wave_noise_coords, _WaveNoise);
			float val = tex2Dlod(_WaveNoise, float4(waveNoiseUV, 0, 1));

			data.vertex.y += lerp(0, _MaxAmplitude, val);
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float2 coords = IN.uv_MainTex;
			coords += float2(_WaveSpeed, _WaveSpeed) * _Time.y;

			float2 flippedCoords = IN.uv_MainTex;
			flippedCoords -= float2(0, _WaveSpeed) * _Time.y;

			float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, IN.uv_MainTex));
			depth = Linear01Depth(depth) + 0.5;

			fixed4 c = tex2D (_WaveTexture, coords);
			
			float4 tint = lerp(_WaterBaseTint, _WaterHighlightTint, c.r);

			o.Albedo = tint;
			o.Alpha = _WaterAlpha;

			o.Smoothness = _Smoothness;

			float3 normal1 = UnpackScaleNormal(tex2D(_WaveNormal1, coords), _NormalIntensity1);
			float3 normal2 = UnpackScaleNormal(tex2D(_WaveNormal2, flippedCoords), _NormalIntensity2);

			o.Normal = normal1 + normal2;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
