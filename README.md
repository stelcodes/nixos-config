# My NixOS Config

My pride and joy. Feel free to take a look around.

## Inspiration

https://github.com/Xe/nixos-configs

https://github.com/MatthiasBenaets/nixos-config

https://git.2li.ch/Nebucatnetzer/nixos

https://github.com/emmanuelrosa/erosanix

https://github.com/LongerHV/nixos-configuration

https://github.com/TLATER/dotfiles

## Other Links

https://librearts.org/

https://diskprices.com

https://www.backblaze.com/cloud-storage/resources/hard-drive-test-data

https://modcase.com.au

https://frame.work

## Gaming

### Wireless Controllers

The Xbox One controllers models 1708 and 1797 are some of best wireless controllers for linux. The package that provides their firmware is called xpadneo.

https://en.wikipedia.org/wiki/Xbox_Wireless_Controller

https://xbox.fandom.com/wiki/List_of_Xbox_Wireless_Controller_variants#Third_Generation_(2016)

https://atar-axis.github.io/xpadneo/

### Emulators

https://emulation.gametechwiki.com/index.php/Main_Page

## Media

https://nixos.wiki/wiki/Kodi

My preferred setup:
```
Services -> Weather -> Gismeteo
Interface -> Skin -> Colors -> Concrete
Media -> Library -> Update library on startup
Media -> Music -> Show Song and Album Artists -> False
Media -> Music -> Split Albums into Discs -> False
Media -> Music -> Default provider for albums -> Local Only
Media -> Music -> Default provider for artists -> Local Only
Media -> Music -> Visualisations -> On
Player -> Music -> Visualisation -> Goom
```
This music sources don't purge missing tracks even when cleaned so you have to remove .kodi/userdata/Database/MyMusic.db all the time. Seems fixable? 🤔
