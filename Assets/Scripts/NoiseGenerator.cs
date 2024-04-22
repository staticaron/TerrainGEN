using UnityEngine;

public static class NoiseGenerator
{
	public static float[,] GenerateNoiseMap(int width, int height, float scale, int seed, int octaves, float lacunarity, float persistance, Vector2 offset)
	{
		System.Random psuedoRandomNumberGen = new System.Random(seed);

		Vector2[] octaveOffsets = new Vector2[octaves];
		for (int i = 0; i < octaves; i++)
		{
			float offsetX = psuedoRandomNumberGen.Next(-100000, 100000) + offset.x;
			float offsetY = psuedoRandomNumberGen.Next(-100000, 100000) + offset.y;
			octaveOffsets[i] = new Vector2(offsetX, offsetY);
		}

		float[,] noiseValues = new float[width, height];

		float halfHeight = height * 0.5f;
		float halfWidth = width * 0.5f;

		float minNoiseHeight = float.MaxValue;
		float maxNoiseHeight = float.MinValue;

		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < height; y++)
			{
				float noiseValue = 0;

				for (int o = 0; o < octaves; o++)
				{
					float sampleX = (x - halfWidth) / scale * Mathf.Pow(lacunarity, o) + octaveOffsets[o].x;
					float sampleY = (y - halfHeight) / scale * Mathf.Pow(lacunarity, o) + octaveOffsets[o].y;

					float perlinValue = Mathf.PerlinNoise(sampleX, sampleY) * 2 - 1;

					noiseValue += perlinValue * Mathf.Pow(persistance, o);
				}

				if (noiseValue < minNoiseHeight) minNoiseHeight = noiseValue;
				else if (noiseValue > maxNoiseHeight) maxNoiseHeight = noiseValue;

				noiseValues[x, y] = noiseValue;
			}
		}

		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < height; y++)
			{
				noiseValues[x, y] = Mathf.InverseLerp(minNoiseHeight, maxNoiseHeight, noiseValues[x, y]);
			}
		}

		return noiseValues;
	}
}
