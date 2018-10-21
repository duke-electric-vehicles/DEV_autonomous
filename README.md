# autonomous
Repo for self-driving related code/data 

### Tutorial to ssh into the TX2:

#### Authentification
Password authentification is disabled because the ip of the Jetson is available in a public repository.  To access the Jetson, you'll have to add your ssh RSA key to the list of trusted keys.

On your personal computer, use `ssh-keygen` if you don't already have a key and copy/paste the contents of the `cat ~/.ssh/id_rsa.pub` command into the "authorized_keys" file in the `ssh` branch (this way, you can ssh into the Jetson as long as you have push rights to the repository).

The Jetson will automatically update the authorized keys each time it reconnects to wifi.  To manually update the authorized keys, you can rerun the "~/DEV_autonomous/autorun.sh" file on the Jetson.

#### Client Side
Copy/paste the following into a terminal window

```
export TX2IP=$(curl -s https://raw.githubusercontent.com/DukeElectricVehicles/DEV_autonomous/ssh/IPaddress)
```

then ssh into the machine by typing

```
ssh -XY nvidia@$TX2IP
```

You can optionally add something like this into your ~/.bash_profile

```
alias sshDEVTX2="ssh nvidia@$(curl -s https://raw.githubusercontent.com/DukeElectricVehicles/DEV_autonomous/ssh/IPaddress)"
```

then simply typing `sshDEVTX2` whenever you want to ssh into the TX2.
