﻿using UnityEngine;
using Sirenix.OdinInspector;

public class Collection : MonoBehaviour
{
	#region Variable
	private Camera playerCamera = new Camera();

	[BoxGroup("Collection Settings:")]
	[Tooltip("Collection Range where Player can Collect")]
	public float range = new float();
	[BoxGroup("Collection Settings:")]
	[Tooltip("Destruction time of the Collected Rock from Collection")]
	[SerializeField] private float rockDistructionTime = 0.5f;
	[BoxGroup("Collection Settings:")]
	[Tooltip("Collection Key that Player needs to press in order to collect it")]
	[SerializeField] private KeyCode pickupKey = KeyCode.F;

	[BoxGroup("Collected Rocks")]
	[Tooltip("Collected Rock amount")]
	public int rockCollected = new int();
	#endregion Variable

	private void Awake()
	{
		// Getting the Main Camera
		playerCamera = GetComponent<Camera>();
	}

	private void Update()
	{
		// Debugging a Ray to show how far Collection Range is
		Debug.DrawRay(transform.position, transform.forward * range, Color.red);

		// Checking for a Rock with a Ray.
		if (Physics.Raycast(playerCamera.transform.position, playerCamera.transform.forward, out RaycastHit hit, range) && hit.transform.CompareTag("Rock") && Input.GetKeyDown(pickupKey))
		{
			// Destroying and Collecting the Rock
			Destroy(hit.transform.gameObject, rockDistructionTime);
			rockCollected++;

			// Debugging when Rock is Collected
			Debug.Log("Collected a new Rock. You have " + rockCollected + " Rocks");
		}
	}
}
