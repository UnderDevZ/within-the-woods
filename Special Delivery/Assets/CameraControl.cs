using UnityEngine;
using Sirenix.OdinInspector;

public class CameraControl : MonoBehaviour
{
	private Transform playerBody;

	[BoxGroup("Inputs:")]
	public string mouseXInputName = "Mouse X";
	[BoxGroup("Inputs:")]
	public string mouseYInputName = "Mouse Y";

	[BoxGroup("Sensitivity")]
	public float mouseSensitivity;

	private float XAxisClamp;

	private void Awake()
	{
		playerBody = GameObject.FindGameObjectWithTag("Player").transform;

		LockCursor();
		XAxisClamp = 0f;
		ClampXAxisRotationToValue(270f);
	}

	private void LockCursor()
	{
		Cursor.lockState = CursorLockMode.Locked;
	}

	private void Update()
	{
		CameraRotation();
	}

	private void CameraRotation()
	{
		float mouseX = Input.GetAxis(mouseXInputName) * mouseSensitivity * Time.deltaTime;
		float mouseY = Input.GetAxis(mouseYInputName) * mouseSensitivity * Time.deltaTime;

		XAxisClamp += mouseY;

		if (XAxisClamp > 90f)
		{
			XAxisClamp = 90f;
			mouseY = 0f;
			ClampXAxisRotationToValue(270f);

		}
		else if (XAxisClamp < -90f) 
		{
			XAxisClamp = 90f;
			mouseY = 0f;
			ClampXAxisRotationToValue(90f);

		}

		transform.Rotate(Vector3.left * mouseY);
		playerBody.Rotate(Vector3.up * mouseX);
	}

	private void ClampXAxisRotationToValue(float value)
	{
		Vector3 eulerRotation = transform.eulerAngles;
		eulerRotation.x = value;
		transform.eulerAngles = eulerRotation;
	}
}
