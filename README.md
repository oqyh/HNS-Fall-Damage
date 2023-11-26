# [HNS] Fall Damage (1.0.2)
https://forums.alliedmods.net/showthread.php?t=340920

### Fall Damage Print + Health Regeneration Fall Damage + God Mode Timer

![alt text](https://github.com/oqyh/HNS-Fall-Damage/blob/main/img/screenshot1.png?raw=true)

![alt text](https://github.com/oqyh/HNS-Fall-Damage/blob/main/img/screenshot2.png?raw=true)


## .:[ ConVars ]:.
 ```
//=========================[ Enable/Disable Plugin ]====================================================

// Enable [CSGO-CSS] HNS Fall Damage Plugin?
// 1= Yes
// 0= No
hns_d_enable_plugin "1"

//===============================[ Settings ]===========================================================

// Enable Regenerate Fall Damage Only
// 1= Yes
// 0= No
hns_d_enable_regen "1"

// if [hns_d_enable_regen 1] Stop Regenerate Fall Damage If Player Got Stabbed?
// 1= Yes
// 0= No (Means Regenerate Health Until Hit Old Health + Knife Damage Ignored)
hns_d_regen_stop "1"

// if [hns_d_enable_regen 1] How Much HP To Give
hns_d_regen_hp "1"

// if [hns_d_regen_hp x] How Many (in sec) To Give HP
hns_d_regen_time "2.0"

// How Much Percent Give HP Regenerate Back
// 3= 1/3 Means One third
// 2= 1/2 Means Half Of it
// 1= Means All Of it
hns_d_regen_per "1"

//===============================[ Misc ]===========================================================

// Enable God Mode For (T) Team
// 2= Yes On Every Spawn Only
// 1= Yes On Every Round Start Only
// 0= No
hns_d_enable_godmode "1"

// if [hns_d_enable_godmode 1 or 2] Give God Mode To (CT) Team Also?
// 1= Yes
// 0= No
hns_d_godmode_ct "0"

// if [hns_d_enable_godmode 1 or 2] For How Many (in Secs) God Mode Should Be On
hns_d_godmode_time "10.0"

//==============================[ Colors / Transparent ]============================================

// Enable Transparent Who God Mode On?
// 1= Yes
// 0= No
hns_d_enable_transparent "1"

// if [hns_d_enable_transparent 1] How Much Transparent On God Mode
// 0= Invisible
// 120= Transparent
// 255=None
hns_d_transparent "120"


//******************************************************************************************************
//*																									   *
//*											[ N O T E ]												   *
//*	To Make Default Color Put These [hns_d_color_r "255"] [hns_d_color_g "255"] [hns_d_color_b "255"]  *
//*																									   *
//******************************************************************************************************

// Body *Red* Code Color Pick Here https://www.rapidtables.com/web/color/RGB_Color.html
hns_d_color_r "255"

// Body *Green* Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html
hns_d_color_g "0"

// Body *Blue* Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html
hns_d_color_b "0"

//=======================[ Messages / Chat ]======================================================

// Send Private Message To Players Who Got GodMode?
// 1= Yes
// 0= No
hns_d_enable_notify_god "1"

// Send Announced Message To All Who Got Fall Damage
// 2= Yes Without Hp Left
// 1= Yes With Hp Left
// 0= No Disable Announcer
hns_d_enable_notify "1"

//===============================================================================================
```


## .:[ Change Log ]:.
```
(1.0.2)
-Fix Bug
-Rework Regen Health To Avoid Overlap
-Rework GodMode Health To Avoid Overlap
-Added hns_d_regen_stop Stop Regenerate Fall Damage If Player Got Stabbed
-Added hns_d_enable_transparent Enable Transparent Who God Mode On
-Added hns_d_transparent How Much Transparent On God Mode
-Added Colors On Models To GodMode [hns_d_color_r, hns_d_color_g, hns_d_color_b]

(1.0.1)
-Fix Bug
-Fix Invalid timer handle 0
-Fix Client 1 is not in game
-Fix Invalid token ' ' in #format property on line 21 + 27
-Fix Regenerate keep on on start round or respawn
-Added hns_d_enable_notify Print Hp Or Without  2= Without HP || 1= With Hp || 0= No
-Added hns_d_regen_per Percent Give HP Regenerate

(1.0.0)
-Initial Release
```

## .:[ Donation ]:.

If this project help you reduce time to develop, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/oQYh)
