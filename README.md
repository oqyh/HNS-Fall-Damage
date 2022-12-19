# [HNS] Fall Damage (1.0.1)
https://forums.alliedmods.net/showthread.php?t=340920

### Fall Damage Print + Health Regeneration Fall Damage + God Mode Timer

![alt text](https://github.com/oqyh/HNS-Fall-Damage/blob/main/img/screenshot1.png?raw=true)

![alt text](https://github.com/oqyh/HNS-Fall-Damage/blob/main/img/screenshot2.png?raw=true)


## .:[ ConVars ]:.
 ```
// Enable [HNS] Fall-Damage Plugin || 1= Yes || 0= No
hns_d_enable_plugin "1"



// Enable God Mode For Ts || 2= On Spawn Only || 1= On Round Start Only || 0= No
hns_d_enable_godmode "1"

// if hns_d_enable_godmode 1 or 2 Give God Mode To CTs Also? || 1= Yes || 0= No
hns_d_godmode_ct "0"

// For How Many (in sec) if hns_d_enable_godmode 1 or 2 God Mode Should Be On
hns_d_godmode_time "10.0"



// Enable Regenerate Fall Damage Only  || 1= Yes || 0= No
hns_d_enable_regen "1"

// How Much HP To Give if hns_d_enable_regen 1
hns_d_regen_hp "1"

// How Much Percent Give HP Regenerate Back example 2= 2% Means Half Of it || 1= 0% Means All Of it
hns_d_regen_per "1"

// How Many (in sec) hns_d_regen_hp Give Hp
hns_d_regen_time "2.0"



// Enable Notification Message To All Who Got Fall Damage || 2= Without HP || 1= With Hp || 0= No
hns_d_enable_notify "1"

// Enable Notification God Mode  || 1= Yes || 0= No
hns_d_enable_notify_god "1"
```


## .:[ Change Log ]:.
```
(1.0.1)
-Fix Bug
-Fix Invalid timer handle 0
-Fix Client 1 is not in game
-Fix Regenerate keep on on start round or respawn
-Added hns_d_enable_notify Print Hp Or Without  2= Without HP || 1= With Hp || 0= No
-Added hns_d_regen_per Percent Give HP Regenerate

(1.0.0)
-Initial Release
```

## .:[ Donation ]:.

If this project help you reduce time to develop, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/oQYh)
