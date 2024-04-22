using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(NoiseMapGenerator))]
public class NoiseMapGeneratorEditor : Editor
{
	public override void OnInspectorGUI()
	{
		NoiseMapGenerator mapGen = (NoiseMapGenerator)target;

		if (DrawDefaultInspector())
		{
			if (mapGen.isAutoUpdating()) mapGen.GenerateAndDisplay(false);
		}

		GUILayout.Space(6);

		if (GUILayout.Button("Generate Map"))
		{
			mapGen.GenerateAndDisplay(false);
		}

	}
}