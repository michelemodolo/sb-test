# ----------------------------------------------------------------------
# I quickly setup this Makefile as a kind of trivial pipeline simulation
# Michele Modolo
# ----------------------------------------------------------------------

# --------------------------------------------------
# Options INSIDE Vagrant box (tested with minikube)
# NOTE: helm installs from a local chart
# -- Suggested usage: "make all-vagrant". Once you got satisfied: "make argocd-cleanup" to clean up.
# --------------------------------------------------
all-vagrant: docker helm-deploy apptest-nonargocd
docker: builddockerimage loaddockerimagetominikube
helm-deploy: localhelminstall
apptest-nonargocd: apptestnonargocd

# ----------------------------------------------------------------------------------------------
# Options OUTSIDE Vagrant box (tested with docker-desktop)
# Prereqs: helm,docker,k8s (e.g. docker-desktop) installed 
# NOTE: helm installs from a remote charts (repo: https://michelemodolo.github.io/sb-helmcharts)
# -- Suggested usage: "make all". Once you got satisfied: "make argocd-cleanup" to clean up.
# ----------------------------------------------------------------------------------------------
all: builddockerimage helm-remote argocd-install argocd-appregistration apptest-argocd
helm-remote: helmremote
argocd-install: argocdinstall
argocd-appregistration: argocdappregistration
apptest-argocd: apptestargocd
argocd-cleanup: argocdcleanup

builddockerimage:
	@echo "\n--------------------------------------------------------";\
	echo "*** I am about to build the alphanumber local docker image...";\
	echo "---------------------------------------------------------\n";\
	cd docker/alphanumber;\
	docker build -t alphanumber:latest . ;\

loaddockerimagetominikube:
	@echo "\n----------------------------------------------------------------";\
	echo "*** I am about to load the 'alphanumber' local docker image to minikube cluster...";\
	echo "-----------------------------------------------------------------\n";\
	minikube image load alphanumber:latest ;\
	echo "done."

localhelminstall:
# ----------------------------------------------------------------------
# NOTE: this is a LOCAL helm install
# ----------------------------------------------------------------------
	@echo "\n-------------------------------------------------------------------------------------------";\
	echo "*** I am now installing the alphanumber app through Helm...";\
	echo "-------------------------------------------------------------------------------------------\n";\
	cd localhelm;\	
	helm install alphanumber alphanumber/ --values alphanumber/values.yaml;\
	echo "\n--------------------------------------------------------------------------------------------------";\
	echo "*** I am giving 40sec to Helm so that it can fully deploy the 'alphanumber' app...";\
	echo "---------------------------------------------------------------------------------------------------\n";\
	sleep 40


apptestnonargocd:
	@echo "\n--------------------------------------------------------------------------------------------------";\
	echo "*** Testing some endpoints... NOTE: special chars (including spaces) are not correctly handed by CURL";\
	echo "---------------------------------------------------------------------------------------------------\n";\
	export NODE_PORT=$(shell kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services alphanumber) ;\
    export NODE_IP=$(shell kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}") ;\
	echo "---------";\
	echo "*** Testing $$NODE_IP:$$NODE_PORT/ready .... ***";\
	curl $$NODE_IP:$$NODE_PORT/ready;\
	echo "---------";\
	echo "*** Testing $$NODE_IP:$$NODE_PORT/Dad .... ***";\
	curl $$NODE_IP:$$NODE_PORT/Dad;\
	echo "---------";\
	echo "*** Testing $$NODE_IP:$$NODE_PORT/Dad37Dad5 .... ***";\
	curl $$NODE_IP:$$NODE_PORT/Dad37Dad;\
	echo "---------";\
	echo "*** Testing $$NODE_IP:$$NODE_PORT/about .... ***";\
	curl $$NODE_IP:$$NODE_PORT/about;\
	echo "---------";\
	echo "*** UP TO YOU: try testing 'curl $$NODE_IP:$$NODE_PORT/whatever' .... ***";\
	echo
	
helmdestroy:
	helm uninstall alphanumber

argocdinstall:
	@echo "\n-------------------------------------------------------------------------------------------";\
	echo "*** I am installing ArgoCD...";\
	echo "-------------------------------------------------------------------------------------------\n";\
	kubectl create namespace argocd;\
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml;\
	echo "\n--------------------------------------------------------------------------------------------------";\
	echo "*** I am giving 40sec to ArgoCD so that all its pods can be running...";\
	echo "---------------------------------------------------------------------------------------------------\n";\
	sleep 40

helmremote:
# ----------------------------------------------------------------------
# NOTE: this is a prerequisite for the ARGOCD-driven app installation!!
# ----------------------------------------------------------------------
	@echo "\n-----------------------------------------------------------------------------------------";\
	echo "*** I am adding the michelemodolo.github.io/sb-helmcharts Helm repo as 'michelemodolo'...";\
	echo "-----------------------------------------------------------------------------------------\n";\
	helm repo add michelemodolo https://michelemodolo.github.io/sb-helmcharts/
	helm repo update
#	helm install alphanumber michelemodolo/alphanumber

argocdappregistration:
	@echo "\n--------------------------------------------------------------------------------------------------";\
	echo "*** I am registering the 'alphanumber' app to ArgoCD...";\
	echo "---------------------------------------------------------------------------------------------------\n";\
	kubectl apply -n argocd -f argocd-alphanumber.yaml;\
	echo "\n--------------------------------------------------------------------------------------------------";\
	echo "*** I am giving 40sec to ArgoCD so that it can fully deploy the 'alphanumber' app...";\
	echo "---------------------------------------------------------------------------------------------------\n";\
	sleep 40

apptestargocd:
	@echo "\n-------------------------------------------------------------------------------------------";\
	echo "*** IN YOUR BROWSER GO TO localhost:8888/whatever-you-want-to-test :";\
	echo "-------------------------------------------------------------------------------------------\n";\
	echo " AFTER you did your tests don't forget to stop the port binding, if still active, by running: \n";\
	echo " 1) ps -ef | grep 'forward svc/alphanumber'  \n";\
	echo " 2) kill -9 THE-PID-YOU-NEED-TO-KILL  \n";\
	kubectl port-forward svc/alphanumber -n argocd 8888:8000;\
	echo 

argocdcleanup:
	kubectl delete ns argocd
