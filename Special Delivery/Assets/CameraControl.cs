using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    [SerializeField] public string mouseXInputName, mouseYInputName;


    [SerializeField] public float mouseSensitivity;

    [SerializeField] private Transform playerBody;

    private float XAxisClamp;


    private void Awake()
    {
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
