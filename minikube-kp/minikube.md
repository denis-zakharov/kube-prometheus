# start
```
minikube start --kubernetes-version=v1.28.3
```

## addons
Addons aktiviert: storage-provisioner, default-storageclass, ingress (nginx)

```
minikube addons list
minikube addons enable ingress
```

## prometheus operator
```
minikube addons disable metrics-server
minikube delete
minikube start --kubernetes-version=v1.28.3 --memory=6g --bootstrapper=kubeadm \
	--extra-config=kubelet.authentication-token-webhook=true \
	--extra-config=kubelet.authorization-mode=Webhook \
	--extra-config=scheduler.bind-address=0.0.0.0 \
	--extra-config=controller-manager.bind-address=0.0.0.0
```

# cleanup
```
docker system prune -a
minikube ssh -- docker system prune -a
```
