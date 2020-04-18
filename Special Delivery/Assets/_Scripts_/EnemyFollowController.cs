// This is Pnguin's Spaghetti code

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyFollowController : MonoBehaviour
{
    public Transform playerFollow;
    public NavMeshAgent agent;
    public int waitSeconds;

    private void Start() {
        StartCoroutine(WaitandExecute());
    }
    private IEnumerator WaitandExecute() {
        while (true) {
            yield return new WaitForSeconds(waitSeconds);
            agent.SetDestination(playerFollow.position);
        }
    }
}
