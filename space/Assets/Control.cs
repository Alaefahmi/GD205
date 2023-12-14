using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Control : MonoBehaviour
{
    public float speed;
    public float rotationSpeed;
    public float jumpSpeed;
   
    private Animator animator;
    private CharacterController characterController;
    private float ySpeed;
    private float originalStepOffset;
    
   
    // Start is called before the first frame update
    void Start()
    { 
       animator = GetComponent < Animator>();
        characterController = GetComponent<CharacterController>();
        originalStepOffset = characterController. stepOffset;
    }

    // Update is called once per frame
    void Update()
    {
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical"); 
   
   
    Vector3 movementDirection = new Vector3(horizontalInput,0,verticalInput);
    float magnitude = movementDirection.magnitude;
    magnitude= Mathf.Clamp01(magnitude);
    movementDirection.Normalize(); 
    
    ySpeed += Physics.gravity.y *Time.deltaTime;
    
   if(characterController.isGrounded)
   {
   
     characterController.stepOffset = originalStepOffset;
    ySpeed = -0.5f;
   
   if (Input.GetButtonDown("Jump"))
   {
    ySpeed = jumpSpeed;
   }
   
   }
    else {
         characterController.stepOffset=0;
    }
    
    
     //transform.Translate(movementDirection* magnitude* speed* Time.deltaTime, Space.World);
   Vector3 velocity = movementDirection *magnitude;
   velocity.y = ySpeed;
   characterController.Move(velocity * Time.deltaTime);



    if (movementDirection != Vector3.zero)
    {
        animator.SetBool("IsMoving", true);
        Quaternion toRotation = Quaternion.LookRotation(movementDirection, Vector3.up);

        transform.rotation = Quaternion.RotateTowards(transform.rotation, toRotation, rotationSpeed * Time.deltaTime);
    }
   else {
    
    animator.SetBool("IsMoving", false);   

   }
   
    }
    
}
