using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyScriptRevised : MonoBehaviour
            
{
    private NavMeshAgent nav;

    public GameObject Player;


   
    // Start is called before the first frame update
    void Start()

    {

        nav = GetComponent<NavMeshAgent>();

        
    }

    // Update is called once per frame
    void Update()
    {

        nav.SetDestination(Player.transform.position);
        
    }
}
