using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Hazard : MonoBehaviour

   {
    public GameObject hazard;
    public GameObject[] hazards;
    Vector3 startPos;

    // Start is called before the first frame update
    void Start()
    {
       startPos = transform.position;
    }

    // Update is called once per frame
   void Update()
    {
        if (Input.GetKeyDown(KeyCode.W)){
            Debug.Log("W key pressed");
            transform.position += Vector3.forward;
        }

        if (Input.GetKeyDown(KeyCode.S)){
            Debug.Log("S key pressed");
            transform.position += Vector3.back;
        }

        if (Input.GetKeyDown(KeyCode.A)){
            Debug.Log("A key pressed");
            transform.position += Vector3.left;
        }

        if (Input.GetKeyDown(KeyCode.D)){
            Debug.Log("D key pressed");
            transform.position += Vector3.right;
        }

       // if (Input.GetKeyDown(KeyCode.Q)){
         //   Debug.Log("Q key pressed");
          //  transform.position += Vector3.up;
        

        //if (Input.GetKeyDown(KeyCode.E)){
           // Debug.Log("E key pressed");
           // transform.position += Vector3.down;
        
    
    for (int i = 0; i < hazards.Length; i++){
            if (transform.position== hazards[i].transform.position)
            {
                 transform.position = startPos;
            }

        }    
    }   
    }


