using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Collection : MonoBehaviour
{
    private SphereCollider rockSphereCollider;

    [SerializeField] private int collectedRocks;

    private void Awake()
    {
        rockSphereCollider = this.gameObject.GetComponent<SphereCollider>();                // Referencing the Sphere Collider
    }

    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log(this.gameObject.name + " collided with " + collision.collider.name);      // Printing the Collided Gameobject's name

        if (collision.collider.tag == "Player")                                             // Checking if the Collided Object's Tag is Player
        {
            collectedRocks++;                                                               // Increasing Collected Rocks Number
            Destroy(this.gameObject);                                                       // Destroying the Collected Rock
        }
    }
}
