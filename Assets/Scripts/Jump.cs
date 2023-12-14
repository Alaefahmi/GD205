using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Jump : MonoBehaviour
{
 
  public Rigidbody rb;
  void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space))
   
       {
        rb.AddForce(Vector3.up * 150);
       }
        
       
    }
}
