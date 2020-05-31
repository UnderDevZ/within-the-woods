
using UnityEngine;

public class GunScript : MonoBehaviour
{

    public float damage = 100f;
    public float range = 100f;
    public ParticleSystem flash;

    public Camera playerCam;

    // Update is called once per frame
    void Update()


    {


        if (Input.GetButtonDown("Fire1")) 

        {

            Shoot();

        }

        void Shoot() 
        {
            flash.Play();

            RaycastHit hit;
            if (

            Physics.Raycast(playerCam.transform.position, playerCam.transform.forward, out hit, range)) 
            {

                Debug.Log(hit.transform.name);
            }
        
        }
    }
}
