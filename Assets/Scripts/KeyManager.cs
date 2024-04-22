using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

public class KeyManager : MonoBehaviour
{
	[SerializeField] KeyCode regenKey;

	[SerializeField] UnityEvent<bool> regenAction;

	private void OnEnable()
	{
		Keyboard.current.onTextInput += KeyPressed;
	}

	private void OnDisable()
	{
		Keyboard.current.onTextInput -= KeyPressed;
	}

	private void KeyPressed(char obj)
	{

		if (obj.ToString().ToLower() == regenKey.ToString().ToLower())
		{
			regenAction.Invoke(true);
		}
	}
}
