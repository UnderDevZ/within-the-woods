using UnityEngine;
using Sirenix.OdinInspector;

public class GunScript : MonoBehaviour
{
	private Camera playerCam;
	[BoxGroup("Reference:")]
	[SerializeField] private ParticleSystem flash = new ParticleSystem();

	[BoxGroup("Gun Settings:")]
	public float damage = 100f;
	[BoxGroup("Gun Settings:")]
	public float range = 100f;

	private void Awake()
	{
		playerCam = Camera.main;
	}

	private void Update()
	{
		Debug.DrawLine(playerCam.transform.position, playerCam.transform.forward * range, Color.red);

		if (Input.GetButtonDown("Fire1"))
		{
			Shoot();
		}
	}

	private void Shoot()
	{
		flash.Play();

		if (Physics.Raycast(playerCam.transform.position, playerCam.transform.forward, out RaycastHit hit, range))
		{
			Debug.Log("Player just shot and hit " + hit.transform.name);
		}
	}
}
