// This is Pnguin's Spaghetti code
/*
 To add a weapon to this system.
 Add the game object to the weapon holder gameobject.
 The order depends on the order it is in the hierarchy from top to bottom.
*/

using UnityEngine;
using Sirenix.OdinInspector;

public class WeaponSwitching : MonoBehaviour
{
	[BoxGroup]
	[Tooltip("Selected weapon slot from 1-10")]
	[Range(0, 9)]
	public int selectedWeapon = new int();

	private void Start()
	{
		SelectWeapon();
	}

	private void Update()
	{
		int previousSelected = selectedWeapon;

		if (Input.GetAxis("Mouse ScrollWheel") > 0){
			if(selectedWeapon >= transform.childCount -1)
				selectedWeapon = 0;
			else selectedWeapon++;
		}

		if (Input.GetAxis("Mouse ScrollWheel") < 0){
			if(selectedWeapon <= 0)
				selectedWeapon = transform.childCount - 1;
			else selectedWeapon--;
		}

		NumberSelectWeaopn();

		if(previousSelected != selectedWeapon)
			SelectWeapon();
	}

	private void SelectWeapon(){
		int i = 0;

		foreach(Transform weapon in transform){
			if(i == selectedWeapon)
				weapon.gameObject.SetActive(true);
			else
				weapon.gameObject.SetActive(false);
			i++;
		}
	}

	//Checks For number input for weapon slot
	private void NumberSelectWeaopn(){
		if(Input.GetKeyDown(KeyCode.Alpha1)){
			selectedWeapon = 0; Debug.Log("Slot 1");}
		if(Input.GetKeyDown(KeyCode.Alpha2) && transform.childCount >= 2){
			selectedWeapon = 1; Debug.Log("Slot 2");}
		if(Input.GetKeyDown(KeyCode.Alpha3) && transform.childCount >= 3){
			selectedWeapon = 2; Debug.Log("Slot 3");}
		if(Input.GetKeyDown(KeyCode.Alpha4) && transform.childCount >= 4){
			selectedWeapon = 3; Debug.Log("Slot 4");}
		if(Input.GetKeyDown(KeyCode.Alpha5) && transform.childCount >= 5){
			selectedWeapon = 4; Debug.Log("Slot 5");}
		if(Input.GetKeyDown(KeyCode.Alpha6) && transform.childCount >= 6){
			selectedWeapon = 5; Debug.Log("Slot 6");}
		if(Input.GetKeyDown(KeyCode.Alpha7) && transform.childCount >= 7){
			selectedWeapon = 6; Debug.Log("Slot 7");}
		if(Input.GetKeyDown(KeyCode.Alpha8) && transform.childCount >= 8){
			selectedWeapon = 7; Debug.Log("Slot 8");}
		if(Input.GetKeyDown(KeyCode.Alpha9) && transform.childCount >= 9){
			selectedWeapon = 8; Debug.Log("Slot 9");}
		if(Input.GetKeyDown(KeyCode.Alpha0) && transform.childCount >= 10){
			selectedWeapon = 9; Debug.Log("Slot 10");}
	}
}
