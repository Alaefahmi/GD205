using TMPro;
using UnityEngine;
//using UnityEngine.UI; 
public class score : MonoBehaviour
{
  public Transform player; 
  public TextMeshProUGUI scoreText;
   
    
    void Update()
    {
      // Debug.Log(player.position.z);
        scoreText.text  = player. position.y .ToString("0");
    }
}
