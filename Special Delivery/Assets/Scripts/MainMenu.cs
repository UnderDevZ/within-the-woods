using Sirenix.OdinInspector;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
	#region Variables
	[BoxGroup("References:")]
	[SerializeField] private AudioMixer mixer;
	[BoxGroup("References:")]
	[SerializeField] private TMP_Dropdown resolutionDropdown;
	[BoxGroup("References:")]
	[SerializeField, ReadOnly] private Resolution[] resolutions = new Resolution[0];
	#endregion Variables

	private void Awake()
	{
		resolutions = Screen.resolutions;

		resolutionDropdown.ClearOptions();

		int currentResolutionIndex = 0;
		List<string> resolutionOptions = new List<string>();
		for (int i = 0; i < resolutions.Length; i++)
		{
			string resolutionOption = resolutions[i].width + " x " + resolutions[i].height;
			Debug.Log(resolutionOption);
			resolutionOptions.Add(resolutionOption);

			if (resolutions[i].width == Screen.currentResolution.width && resolutions[i].height == Screen.currentResolution.height)
			{
				currentResolutionIndex = i;
			}
		}

		resolutionDropdown.AddOptions(resolutionOptions);
		resolutionDropdown.value = currentResolutionIndex;
		resolutionDropdown.RefreshShownValue();
	}

	#region Main Menu
	/// <summary>Loads Next Level on called</summary>
	public void LoadNextLevel()
	{
		SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
	}

	/// <summary>Quits the Game on called</summary>
	public void QuitGame()
	{
		Application.Quit();

		// Comment this out to build the game. Ctrl + K, Ctrl + C to comment selection. Ctrl + K, Ctrl + U to uncomment selection. 
		//if (UnityEditor.EditorApplication.isPlaying == true)
		//{
		//	UnityEditor.EditorApplication.isPlaying = false;
		//}
	}
	#endregion Main Menu

	#region Main Menu - Settings -  Audio
	/// <summary>Changes Volume of the Game</summary><param name="volume">Takes in the Volume Amount</param>
	public void Volume(float volume)
	{
		if (!(volume <= 20f && volume >= -80))
		{
			Mathf.Clamp(volume, -80f, 20f);
		}

		mixer.SetFloat("Volume", volume);
	}
	#endregion Main Menu - Audio

	#region Main Menu - Settings -  Video
	/// <summary>Changes the Screen mode</summary><param name="isFullscreen">Takes true or false isFullscreen sets the scrren using that</param>
	public void SetFullScreen(bool isFullscreen)
	{
		Screen.fullScreen = isFullscreen;
		Debug.Log("Full screen window = " + isFullscreen);
	}

	/// <summary>Sets Resolution using index</summary><param name="resolutionIndex">Changes the Resolution using this index</param>
	public void SetResolution(int resolutionIndex)
	{
		Resolution resolution = resolutions[resolutionIndex];
		Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreen);
	}

	/// <summary>Sets the Graphics Quality</summary><param name="qualityIndex">Sets the Graphics using this index</param>
	public void SetQuality(int qualityIndex)
	{
		QualitySettings.SetQualityLevel(qualityIndex);
	}
	#endregion Main Menu - Video

	#region Main Menu - Settings - Controls
	// Controls are also coming soon...
	#endregion Main Menu - Settings - Controls
}
