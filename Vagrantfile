# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
#
# Added private_network for making browser tests more convenient
# Otherwise... browser test (within Vagrant) would only be possible
# through curl (within Vagrant)!! (M. Modolo)
#
    config.vm.network "private_network", ip: "192.168.99.99"
#
    config.vm.box = "ubuntu/focal64"
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
        vb.cpus = "4"
        # https://github.com/hashicorp/vagrant/issues/11777#issuecomment-661076612
        vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        vb.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
    end
    config.vm.provision "shell", inline: <<-SHELL
        apt-get update && apt-get upgrade -y
        apt-get install -y curl docker.io snapd git golang python3 python3-pip
        systemctl enable docker
        systemctl start docker
        usermod -aG docker vagrant
        # Install kubectl
        curl -Lso /tmp/kubectl "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
        install -m 755 /tmp/kubectl /usr/local/bin
        # Install and start minikube
        curl -Lso /tmp/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        install -m 755 /tmp/minikube /usr/local/bin/
        sudo -u vagrant MINIKUBE_IN_STYLE=0 minikube start --driver=docker 2>/dev/null
        # Install Helm
        curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
        # Install ArgoCD
        kubectl create namespace argocd
        kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
        # Clone repo
        git clone -b development https://github.com/michelemodolo/sb-test.git
        # Enter $HOME/sb-test (i.e. the sb-test repo)
        cd sb-test
    SHELL
    config.vm.synced_folder ".", "/syncd"
    config.vm.boot_timeout = 600
  end