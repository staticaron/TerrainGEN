using UnityEngine;

public class MapDisplay : MonoBehaviour
{
	[SerializeField] Terrain terrain;
	[SerializeField] float scale;

	public void Display(float[,] noise, Texture2D colorMap)
	{
		for (int x = 0; x < noise.GetLength(0); x++)
		{
			for (int y = 0; y < noise.GetLength(1); y++)
			{
				noise[x, y] *= scale;
			}
		}

		terrain.terrainData.SetHeights(0, 0, noise);
		terrain.materialTemplate.SetTexture("_ColorMap", colorMap);
	}
}
