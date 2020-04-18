using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [SerializeField] private string horizontalInputName;
    [SerializeField] private string verticalInputName;
    [SerializeField] public float moveSpeed;
    [SerializeField] private AnimationCurve jumpFallOff;
    [SerializeField] public float jumpMultiplier;
    [SerializeField] private KeyCode jumpkey;



    private bool isJumping;

    private CharacterController charController;

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
        if (Input.GetKeyDown(jumpkey) && isJumping )

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
        } while (charController.isGrounded && charController.collisionFlags != CollisionFlags.Above);




        isJumping = false;

         
    
    
    }





}
