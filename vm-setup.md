### Useful for VM creation
* Necessary package
	* sudo with root
	* vim
	* git
* add llebugle or user to /etc/sudoers
* git 
	* ssh-keygen -t ed25519 -C "llebugle@student.s19.be"
	* cat .ssh/id_ed25519.pub
* SSH
	* In VirtualBox, enable Adapter 1 = NAT. Add Port Forward: Host Port 2222 → Guest Port 22 (TCP).
	```
	sudo apt update && sudo apt install -y openssh-server
	```
	* Connecting:
	```
	ssh -p 2222 user@127.0.0.1
	```
* Shared folder
	* host: 
	```
	VBoxManage sharedfolder add "inception-vm" --name src --hostpath /Users/you/path/inception --automount
	```
	* VM:
	```
	sudo mkdir -p /mnt/src
    sudo mount -t vboxsf src /mnt/src
    sudo mount --bind /mnt/src ~/inception
	```
* ports:
	* VBoxManage modifyvm "inception-vm" --natpf1 "nginx,tcp,,8081,,8081"
