#### Contents of the preconfiguration file (for Buster)
### Localization
# Preseeding only locale sets language, country and locale.
d-i debian-installer/locale string en_US.UTF-8

# Keyboard selection.
d-i keyboard-configuration/xkb-keymap select us

### Network configuration
# Disable auto-configuration and use the network interface.
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string debian-docker-host
d-i netcfg/get_domain string vm.local

### Mirror settings
# Mirror settings for installing packages from the Internet.
d-i mirror/country string manual
d-i mirror/http/hostname string httpredir.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

### Account setup
# Root password (either set a password or use passwordless sudo below).
d-i passwd/root-password password {{ op://HomeLab/docker-host SSH key/password }}
d-i passwd/root-password-again password {{ op://HomeLab/docker-host SSH key/password }}
# To create a normal user account.
d-i passwd/user-fullname string Coachlight HomeLab
d-i passwd/username string coachlight-homelab
d-i passwd/user-password password "op://HomeLab/coachlight-homelab SSH key/user credentials/password"
d-i passwd/user-password-again password "op://HomeLab/coachlight-homelab SSH key/user credentials/password"
d-i user-setup/allow-password-weak boolean false
d-i user-setup/encrypt-home boolean false
d-i preseed/late_command string in-target sh -c 'mkdir -p /home/coachlight-homelab/.ssh && echo '"op://HomeLab/coachlight-homelab SSH key/public key"' > /home/coachlight-homelab/.ssh/authorized_keys'


### Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string US/Eastern
d-i clock-setup/ntp boolean true

### Partitioning
# Method for partitioning the hard disk.
d-i partman-auto/method string regular
# If one of the disks that are going to be automatically partitioned
# contains an old LVM configuration, the user will normally receive a
# warning. This can be preseeded away...
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
# The same applies to pre-existing software RAID array:
d-i partman-md/device_remove_md boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select Finish partitioning and write changes to disk
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

### Base system installation
# Selecting and installing software.
tasksel tasksel/first multiselect standard, ssh-server
d-i pkgsel/include string openssh-server sudo curl

### Boot loader installation
# Grub is the default boot loader (for x86). Install it to the MBR.
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev  string default

### Finishing up the installation
d-i finish-install/reboot_in_progress note

### Advanced options
# Avoid that last message about the install being complete.
d-i debian-installer/exit/poweroff boolean false
