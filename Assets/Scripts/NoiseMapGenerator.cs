using System;
using UnityEngine;

public enum DrawMode
{
	HeightMap,
	ColorMap
}

public class NoiseMapGenerator : MonoBehaviour
{
	[SerializeField] DrawMode drawMode;

	[SerializeField] int mapWidth;
	[SerializeField] int mapHeight;
	[SerializeField] float scale;

	[SerializeField] int seed;
	[SerializeField] int octaves;
	[SerializeField] float lacunarity;

	[Range(0, 1)]
	[SerializeField] float persistance;

	[SerializeField] Vector2 offset;

	[SerializeField] bool autoUpdate;

	[SerializeField] ColorDetails[] colorDetails;

	public void GenerateAndDisplay(bool isRandom)
	{
		if (isRandom) seed = seed + 1;

		float[,] noise = NoiseGenerator.GenerateNoiseMap(mapWidth, mapHeight, scale, seed, octaves, lacunarity, persistance, offset);

		Texture2D tex = drawMode == DrawMode.ColorMap ? GenerateTexture(GetColorMapFromNoise(noise)) : GenerateTexture(GetHeightMapFromNoise(noise));
		GetComponent<MapDisplay>().Display(noise, tex);
	}

	public Texture2D GenerateTexture(Color[] colorValues)
	{
		Texture2D colorMap = new Texture2D(mapWidth, mapHeight);

		colorMap.SetPixels(colorValues);
		colorMap.Apply();

		colorMap.filterMode = FilterMode.Point;
		colorMap.wrapMode = TextureWrapMode.Clamp;

		return colorMap;
	}

	private Color[] GetHeightMapFromNoise(float[,] noise)
	{
		Color[] heightValues = new Color[noise.GetLength(0) * noise.GetLength(1)];

		for (int x = 0; x < noise.GetLength(0); x++)
		{
			for (int y = 0; y < noise.GetLength(1); y++)
			{
				heightValues[x * mapHeight + y] = Color.Lerp(Color.black, Color.white, noise[x, y]);
			}
		}

		return heightValues;
	}

	private Color[] GetColorMapFromNoise(float[,] noise)
	{
		Color[] heightColors = new Color[noise.GetLength(0) * noise.GetLength(1)];

		for (int x = 0; x < noise.GetLength(0); x++)
		{
			for (int y = 0; y < noise.GetLength(1); y++)
			{
				foreach (ColorDetails colorDetail in colorDetails)
				{
					if (noise[x, y] > colorDetail.height)
					{
						heightColors[x * mapHeight + y] = colorDetail.color;
					}
				}
			}
		}

		return heightColors;
	}

	private void OnValidate()
	{
		if (mapWidth < 0) mapWidth = 1;
		if (mapHeight < 0) mapHeight = 1;

		if (octaves < 0) octaves = 0;
		if (lacunarity < 1) lacunarity = 1;
	}

	public bool isAutoUpdating()
	{
		return autoUpdate;
	}
}

[Serializable]
public struct ColorDetails
{
	public string identifier;
	[Range(0, 1)] public float height;
	public Color color;
}
