# sb-test
This repo allows you to quickly deploy a test app (named 'alphanumber') onto a K8S cluster. 

<b>You have 2 DIFFERENT OPTIONS of using this repo (trying both is warmly suggested).</b>
<br>Option 1) uses Helm only. Option 2) uses ArgoCD (which in turn uses Helm).


<h3>1) YOU CAN USE A VAGRANT BOX.</h3>
The Vagrantfile in this repo builds such a box with everything bundled inside: docker, kubectl,minikube, Helm and... this repo too. Of course you must already have 'vagrant' and 'virtualbox' installed in your machine.
<br><br><u>Instructions</u>:
<br>1.a - clone this repo
<br>1.b - run "vagrant up"
<br>1.c - run "vagrant ssh" to enter your vagrant box
<br>1.d - run "cd sb-test" to enter this repo (automatically cloned at the Vagrant build)
<br>1.e - <b>run "make all-vagrant"</b>: just read the emitted logs and... enjoy!
<br><b>NOTE:</b> This option, just for showing how to do that, uses a Helm deployment of a LOCAL CHART which is pulled from this repo (./localhelm/alphanumber)

<br><br>
<h3>2) YOU CAN DIRECTLY USE YOUR OWN MACHINE.</h3>
You must have already installed docker, kubectl, Helm and a kubernetes distribution of your choice (this code was successfully tested with docker-desktop for Mac).
<br><br><u>Instructions:</u>
<br>2.a - clone this repo
<br>2.b - enter this repo (by simply running "cd sb-test" after you cloned this repo)
<br>2.c - verify that your kubectl is pointing to the kubernetes cluster of your choice (just run "kubectl config get-contexts") and run "kubectl config use-context my-cluster-name" IF needed
<br>2.d - <b>run "make all"</b>: just read the emitted logs and... enjoy!
<br>2.e - after testing, run "make argocd-cleanup" for cleaning up what "make all" built
<br><b>NOTE:</b> This option uses a Helm deployment of a REMOTE CHART which is pulled from a remote helm charts repo (namely https://github.com/michelemodolo/sb-helmcharts). That likely is the most convenient way of exploiting Helm.

<br>
I hope you enjoyed ;-)

