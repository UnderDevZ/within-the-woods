using UnityEngine;
using Sirenix.OdinInspector;

public class CameraControl : MonoBehaviour
{
	private Transform playerBody;

	[BoxGroup("Inputs:")]
	public string mouseXInputName = "Mouse X";
	[BoxGroup("Inputs:")]
	public string mouseYInputName = "Mouse Y";

	[BoxGroup("Mouse Settings:")]
	public float mouseSensitivity;
	[BoxGroup("Mouse Settings:")]
	public bool invertMouseRotation = false;
	[BoxGroup("Mouse Settings:")]
	[MinMaxSlider(-360f, 360f)]
	[SerializeField] private Vector2 xAxisClamp = new Vector2(-90f, 90f);

	private float xRotation = new float();

	private void Awake()
	{
		playerBody = GameObject.FindGameObjectWithTag("Player").transform;

		HideAndLockCursor();
	}

	private void HideAndLockCursor()
	{
		Cursor.lockState = CursorLockMode.Locked;
		Cursor.visible = false;
	}

	private void Update()
	{
		MouseCameraRotation();
	}

	private void MouseCameraRotation()
	{
		float mouseX = Input.GetAxis(mouseXInputName) * mouseSensitivity * Time.deltaTime;
		float mouseY = Input.GetAxis(mouseYInputName) * mouseSensitivity * Time.deltaTime;

		if(invertMouseRotation == false)
			xRotation -= mouseY;
		else if (invertMouseRotation == true)
			xRotation += mouseY;

		xRotation = Mathf.Clamp(xRotation, xAxisClamp.x, xAxisClamp.y);

		transform.localRotation = Quaternion.Euler(xRotation, 0f, 0f);
		playerBody.Rotate(Vector3.up * mouseX);
	}
}
