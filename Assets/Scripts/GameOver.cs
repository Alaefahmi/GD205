using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;



public class GameOver : MonoBehaviour
{
  void OnCollisionEnter(Collision collision)
  {
    if (collision.gameObject.tag == "Player")
    {
         SceneManager.LoadScene(2);
    }
  }

public void RestartGame()
{
     SceneManager.LoadScene(1);
}



}
