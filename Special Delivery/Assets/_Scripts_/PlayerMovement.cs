using UnityEngine;
using System.Collections;
using Sirenix.OdinInspector;

public class PlayerMovement : MonoBehaviour
{
	private CharacterController charController;

	[BoxGroup("Inputs:")]
	[SerializeField] private string horizontalInputName = "Horizontal";
	[BoxGroup("Inputs:")]
	[SerializeField] private string verticalInputName = "Vertical";
	[BoxGroup("Inputs:")]
	[SerializeField] private KeyCode jumpkey = KeyCode.Space;

	[BoxGroup("Movement Settings:")]
	[SerializeField] public float moveSpeed;
	[BoxGroup("Movement Settings:")]
	[SerializeField] private AnimationCurve jumpFallOff = new AnimationCurve();
	[BoxGroup("Movement Settings:")]
	[SerializeField] public float jumpMultiplier;

	[BoxGroup("Values:")]
	[SerializeField, ReadOnly] private bool isJumping;

	private void Awake()
	{
		charController = GetComponent<CharacterController>();
	}

	private void Update()
	{
		PlayerMove();
	}

	private void PlayerMove() 
	{
		float vertInput = Input.GetAxis(verticalInputName) * moveSpeed * Time.deltaTime;
		float horiInput = Input.GetAxis(horizontalInputName) * moveSpeed * Time.deltaTime;

		Vector3 forwardMovement = transform.forward * vertInput;
		Vector3 rightMovement = transform.right * horiInput;

		charController.SimpleMove(forwardMovement + rightMovement);
	}

	private void JumpInput() 
	{
		if (Input.GetKeyDown(jumpkey) && isJumping)
		{
			isJumping = true;
			StartCoroutine(jumpEvent());
		}
	}

	private IEnumerator jumpEvent() 
	{
		float timeInAir = 0f;

		do
		{
			float jumpForce = jumpFallOff.Evaluate(timeInAir);

			charController.Move(Vector3.up * jumpForce * jumpMultiplier * Time.deltaTime);
			timeInAir += Time.deltaTime;
			yield return null;
		}
		while (charController.isGrounded && charController.collisionFlags != CollisionFlags.Above);

		isJumping = false;
	}
}
