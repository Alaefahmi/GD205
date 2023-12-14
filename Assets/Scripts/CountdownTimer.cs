using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;


public class CountdownTimer : MonoBehaviour
{
    float currentTime = 0f;
    float startingTime = 100f;
   
   public TextMeshProUGUI countdownText;
   
    void Start()
    {
        currentTime = startingTime;
        Destroy(gameObject,100f);
    }

void Update()
{
    currentTime -= 1* Time.deltaTime;
   countdownText . text = currentTime.ToString("0");

   if(currentTime <=0){
    currentTime = 0;
   }
}




}