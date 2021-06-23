# sb-test
This repo allows you to quickly deploy a test app (named 'alphanumber') onto a K8S cluster. 

<b>You have 2 DIFFERENT OPTIONS of using this repo:</b>
1) <b>You can use a Vagrant box.</b> The Vagrantfile in this repo builds such a box with everything bundled inside: docker, kubectl,minikube, Helm and... this repo too. Of course you must already have 'vagrant' and 'virtualbox' installed in your machine.
<br><u>Instructions</u>:
- clone this repo
- run "vagrant up"
- run "vagrant ssh" to enter your vagrant box
- run "cd sb-test" to enter this repo (automatically cloned at the Vagrant build)
- <b>run "make all-vagrant"</b>: just read the emitted logs and... enjoy!
<br><b>NOTE:</b> This option, just for showing how to do that, uses a Helm deployment of a LOCAL CHART which is pulled from this repo (./localhelm/alphanumber)

2) <b>You can use your own machine.</b> You must have already installed docker, kubectl, Helm and a kubernetes distribution of your choice (this code was successfully tested with docker-desktop).
<br><u>Instructions:</u>
- clone this repo
- enter this repo (by simply running "cd sb-test" after you cloned this repo)
- verify that your kubectl is pointing to the kubernetes cluster of your choice (just run "kubectl config get-contexts") and run "kubectl config use-context my-cluster-name" IF needed
- <b>run "make all"</b>: just read the emitted logs and... enjoy!
- after testing, run "make argocd-cleanup" for cleaning up what "make all" built
<br><b>NOTE:</b> This option uses a Helm deployment of a REMOTE CHART which is pulled from a remote helm charts repo (namely https://github.com/michelemodolo/sb-helmcharts). That likely is the most convenient way of exploiting Helm. 

