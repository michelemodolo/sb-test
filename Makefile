# ----------------------------------------------------------------------
# I quickly setup this Makefile as a kind of trivial pipeline simulation
# Michele Modolo
# ----------------------------------------------------------------------

all: docker helm-deploy
docker: build-docker-image load-docker-image-to-minikube
helm-deploy: localhelm-install helm-describe
helm-destroy: helm-destroy
app-test: apptest


build-docker-image:
	@echo "\n--------------------------------------------------------";\
	echo "*** I am about to build the alphanumber local docker image...";\
	echo "---------------------------------------------------------\n";\
	cd docker/alphanumber;\
	docker build -t alphanumber:latest . ;\

load-docker-image-to-minikube:
	@echo "\n--------------------------------------------------------";\
	echo "*** I am about to load the 'alphanumber' local docker image to minikube cluster...";\
	echo "---------------------------------------------------------\n";\
	minikube image load alphanumber:latest ;\
	echo "done."

localhelm-install:
	@echo "\n-------------------------------------------------------------------------------------------";\
	echo "*** I am now installing the alphanumber app through Helm...";\
	echo "-------------------------------------------------------------------------------------------\n";\
	cd localhelm;\
	helm install alphanumber alphanumber/ --values alphanumber/values.yaml

helm-describe:
	@echo "\n-------------------------------------------------------------------------------------------";\
	echo "*** Address to CURL the alphanumber app WITHIN this vagrant VM:";\
	echo "-------------------------------------------------------------------------------------------\n";\
	export NODE_PORT=$(shell kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services alphanumber) ;\
    export NODE_IP=$(shell kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}") ;\
    echo "*** $$NODE_IP:$$NODE_PORT ***";\
	echo "EXAMPLES: 'curl $$NODE_IP:$$NODE_PORT/ready','curl $$NODE_IP:$$NODE_PORT/Dad' etc...";\
	echo "You MAY also CHOOSE to simply run 'make app-test'. Enjoy!";\
	echo

apptest:
		@echo "\n-------------------------------------------------------------------------------------------";\
	echo "*** Address to CURL the alphanumber app WITHIN this vagrant VM:";\
	echo "-------------------------------------------------------------------------------------------\n";\
	curl $$NODE_IP:$$NODE_PORT/ready;\
	echo "---------";\
	curl $$NODE_IP:$$NODE_PORT/Dad;\
	echo "---------";\
	curl $$NODE_IP:$$NODE_PORT/Dad37Dad;\
	echo "---------";\
	curl $$NODE_IP:$$NODE_PORT/about;\
	echo "---------";\
	echo
	
helm-destroy:
	helm uninstall alphanumber

argocd-install:
	kubectl create namespace argocd;\
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


