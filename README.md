# My NixOS Config

Feel free to take a look around 🌷✨

## Inspiration

https://github.com/Xe/nixos-configs

https://github.com/MatthiasBenaets/nixos-config

https://git.2li.ch/Nebucatnetzer/nixos

https://github.com/emmanuelrosa/erosanix

https://github.com/LongerHV/nixos-configuration

https://github.com/TLATER/dotfiles

## Essential Resources

### Nix

https://search.nixos.org

https://noogle.dev

https://nixos-and-flakes.thiscute.world

https://www.nixhub.io/

https://nixpk.gs/pr-tracker.html

```
man configuration.nix
man home-configuration.nix
```

### Linux

https://docs.kernel.org/admin-guide/kernel-parameters.html

## Installer Media
```
nix build .#nixosConfigurations.installer-base.config.formats.install-iso
nix build .#nixosConfigurations.installer-base.config.formats.install-iso-gnome
nix build .#nixosConfigurations.installer-base.config.formats.install-iso-plasma
```


## Virtualisation

build vm image:
```
nixos-rebuild build-vm-with-bootloader --flake "$HOME/nixos-config#hostname"
```

test ssh:
```
QEMU_NET_OPTS='hostfwd=tcp::2222-:22' <vm_start_script>
```

ssh into virtual machine by getting ip address (ip a) and `ssh <user>@ip`.

build digital ocean droplet image:
```
nix build .#nixosConfigurations.hostname.config.formats.do
```

## Wayland

Use `QT_QPA_PLATFORM=xcb audacious` to see controls for adjusting plugin windows (Wayland QT issues)

## Dconf

Values can be defined with Home Manager's `dconf.settings` option.

```
dconf dump /org/cinnamon/ | dconf2nix | nvim -R
pkgs.gnome.dconf-editor for GUI
```

## Messaging

My favorites:

```
XMPP: pkgs.gajim
Signal: pkgs.signal-desktop
```

## Obsidian

Might have to `rm -rf ~/.config/obsidian/GPUCache` after a major update.

## Phone tethering

For iphone hotspot tethering use `pkgs.libimobiledevice` and `services.usbmuxd.enable`.

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

## Compatibility

`pkgs.appimage-run`

## Wallpapers

https://github.com/kitsunebishi/Wallpapers

https://imgur.com/upload

## Traditional Desktop Specialisations

```nix
{
  specialisation = {
    gnome.configuration = {
      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-user-docs
        orca
        baobab
        epiphany
        gnome.gnome-backgrounds
        gnome.gnome-color-manager
        gnome.gnome-themes-extra
        gnome.gnome-shell-extensions
        gnome.yelp
        gnome.cheese
        gnome.gnome-contacts
        gnome.gnome-music
        gnome.gnome-system-monitor
        gnome-text-editor
        gnome.gnome-clocks
        gnome.gnome-weather
        gnome.gnome-maps
        gnome.simple-scan
        gnome.gnome-characters
        gnome-connections
        gnome.gnome-logs
        gnome.totem
        gnome.geary
        gnome-photos
        gnome.gnome-calendar
      ];
      services.xserver = {
        autorun = true;
        desktopManager.gnome.enable = true;
      };
    };
    plasma.configuration = {
      environment.plasma5.excludePackages = [ ];
      home-manager.users.${username}.qt.enable = lib.mkForce false;
      services = {
        gnome.gnome-keyring.enable = lib.mkForce false;
        xserver = {
          autorun = true;
          desktopManager.plasma5 = {
            enable = true;
            # useQtScaling = true;
          };
        };
      };
    };
  };
}
```

## Other Links

https://librearts.org/

https://diskprices.com

https://www.backblaze.com/cloud-storage/resources/hard-drive-test-data

https://modcase.com.au

https://frame.work
