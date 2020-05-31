using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Collector : MonoBehaviour
{
    public float reach;

    public Text textBox;

    public Camera cam;

    private int collected;

    

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        SelectCollectible();

        
    }

    private void SelectCollectible()
    {
        RaycastHit hit;

        Ray ray = cam.ScreenPointToRay(Input.mousePosition);


        if (Physics.Raycast(ray, out hit, reach)) {
            if (hit.collider.CompareTag("Collectible")) {
                if (Input.GetKeyDown(KeyCode.C)) {
                    Destroy(hit.transform.gameObject);
                    collected++;
                    textBox.text = "Collected: " + collected;
                }
            }
        }
    }


}
