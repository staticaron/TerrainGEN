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
		_WaterSurfaceTint("Water Surface Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_WaterAlpha("Water Alpha", Range(0, 1)) = 0.5

		_WaveSpeed("Wave Speed", Float) = 1.0

		_Smoothness("Smoothness", Range(0, 1)) = 1.0

		_DepthDifferenceGradient("Depth Difference Gradient", Float) = 1.0
		_DepthDifferenceMask("Depth Difference Mask", Float) = 1.0
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

		sampler2D _WaveNoise;
		float4 _WaveNoise_ST;

		float _MaxAmplitude;

		sampler2D _WaveNormal1;
		sampler2D _WaveNormal2;

		float _NormalIntensity1;
		float _NormalIntensity2;

		float4 _WaterHighlightTint;
		float4 _WaterBaseTint;
		float4 _WaterSurfaceTint;
		float _WaterAlpha;

		float _WaveSpeed;

		float _Smoothness;

		float _DepthDifferenceGradient;
		float _DepthDifferenceMask;

		sampler2D _CameraDepthTexture;
		float4 _CameraDepthTexture_TexelSize;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_WaveNoise;
			float4 screenPos;
			float4 noiseMask;
		};

		float SurfaceIntersectionMask(float4 screenPos, bool returnGradient, float diff)
		{
			float2 uv              = screenPos.xy / screenPos.w;
			float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
			float surfaceDepth    = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);

			float depthDifference = backgroundDepth - surfaceDepth;

			float gradient = saturate(1 - depthDifference / diff);
			int mask = depthDifference <= diff;

			return lerp(mask, gradient, returnGradient);
		}
		void vert(inout appdata_full data, out Input o)
		{
			float2 wave_noise_coords = data.texcoord;
			wave_noise_coords.xy += _WaveSpeed * _Time.y;

			float2 waveNoiseUV = TRANSFORM_TEX(wave_noise_coords, _WaveNoise);
			float4 noiseMask = tex2Dlod(_WaveNoise, float4(waveNoiseUV, 0, 1));

			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.noiseMask = noiseMask;

			data.vertex.y += lerp(0, _MaxAmplitude, noiseMask.r);
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float2 coords = IN.uv_MainTex;
			coords += float2(_WaveSpeed, _WaveSpeed) * _Time.y;

			float2 flippedCoords = IN.uv_MainTex;
			flippedCoords -= float2(0, _WaveSpeed) * _Time.y;

			float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, IN.uv_MainTex));
			depth = Linear01Depth(depth) + 0.5;

			float4 baseColor = lerp(_WaterBaseTint, _WaterHighlightTint, SurfaceIntersectionMask(IN.screenPos, true, _DepthDifferenceGradient));
			
			o.Albedo = lerp(baseColor, _WaterSurfaceTint, SurfaceIntersectionMask(IN.screenPos, true, _DepthDifferenceMask));
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
