Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.network "private_network", ip: "192.168.66.65"
  config.vm.provision "file", source: "install.sh", destination: "install.sh"
  config.vm.provision "file", source: "install-client.sh", destination: "install-client.sh"
  config.vm.provision "file", source: "nginx.conf", destination: "/tmp/nginx.conf"
  config.vm.provision "shell", path: "install.sh"
  config.vm.provision "shell", path: "install-client.sh"
end
