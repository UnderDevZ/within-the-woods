using UnityEngine.SceneManagement;
using UnityEngine;

public class NextSceneScript : MonoBehaviour
{
    public void NextLevel()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }
}
