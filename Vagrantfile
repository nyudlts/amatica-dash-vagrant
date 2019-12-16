
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.network "private_network", ip: "192.168.66.65"
  config.vm.provision "file", source: "install.sh", destination: "install.sh"
  config.vm.provision "shell", path: "install.sh"
end
