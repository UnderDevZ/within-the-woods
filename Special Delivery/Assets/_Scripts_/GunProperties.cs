// This is Pnguin's Spaghetti code

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class GunProperties : MonoBehaviour
{
    [Header("Gun Settings")]
    [Tooltip("How Far the gun can shoot")]
    public float range;
    [Tooltip("Higher the number the faster it shoots./ Number of times gun shoots per second")]
    public float fireRate;
    public int maxAmmo;
    private int currentAmmo;
    [Tooltip("Time to reload in seconds")]
    public float reloadtime;
    private bool isReloading;
    private float nextFire = 0f;
    
    [Header("Resource Refrences")]
    [Tooltip("Camera Will Shoot From this camera")]
    public Camera weaponCam;
    public Animator animator;
    public Text ammoTextBox;
    public GameObject TextHolder;
    public AudioSource gunShot;


    void Start() {
        currentAmmo = maxAmmo;
        ammoTextBox.text = currentAmmo + " / " + maxAmmo;
    }
    private void OnEnable() {
        isReloading = false;
        //Here you set animator to false
        animator.SetBool("Reloading", false);
        TextHolder.SetActive(true);
    }
    private void OnDisable() {
        TextHolder.SetActive(false);
    }
    void Update()
    {
        ammoTextBox.text = currentAmmo + " / " + maxAmmo;
        if (isReloading)
            return;
        //Reloading
        if(Input.GetKeyDown(KeyCode.R)){
            StartCoroutine(Reload());
            return;
        }
        //Shooting
        if (Input.GetButton("Fire1") && Time.time >= nextFire && currentAmmo > 0){
            nextFire = Time.time + 1f/fireRate;
            Shoot();
        }
    }

    IEnumerator Reload(){
        isReloading = true;
        Debug.Log("Reloading");
        animator.SetBool("Reloading", true);
        yield return new WaitForSeconds(reloadtime - .25f);
        animator.SetBool("Reloading", false);
        yield return new WaitForSeconds(.25f);
        currentAmmo = maxAmmo;
        isReloading = false;
    }
    private void Shoot(){
        //Controls animator and sound effects
        if (gunShot.isPlaying) {
            gunShot.Stop();
        }
        gunShot.Play();
        animator.SetTrigger("ShootGun");


        currentAmmo--;

        //Shoots Raycast
        RaycastHit hit;
        bool hitObject = Physics.Raycast(weaponCam.transform.position, weaponCam.transform.forward, out hit, range);
        if(hitObject){
            Debug.Log(hit.transform.name);
        }
    }
}
