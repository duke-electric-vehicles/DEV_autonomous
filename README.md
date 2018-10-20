# autonomous
Repo for self-driving related code/data 

### Tutorial to ssh into the TX2:

Copy/paste the following into a terminal window

```
export TX2IP=$(curl -s https://raw.githubusercontent.com/DukeElectricVehicles/DEV_autonomous/master/IPaddress)
```

then ssh into the machine by typing

```
ssh -XY nvidia@$TX2IP
```

You can optionally add something like this into your ~/.bash_profile

```
alias sshDEVTX2="ssh nvidia@$(curl -s https://raw.githubusercontent.com/DukeElectricVehicles/DEV_autonomous/master/IPaddress)"
```

then simply typing `sshDEVTX2` whenever you want to ssh into the TX2.
