# prometheus operator
Start minikube for Prometheus Operator.

```
# delete previous one
# minikube stop
# minikube delete
minikube start --memory=8g --bootstrapper=kubeadm \
	--extra-config=kubelet.authentication-token-webhook=true \
	--extra-config=kubelet.authorization-mode=Webhook \
	--extra-config=scheduler.bind-address=0.0.0.0 \
	--extra-config=controller-manager.bind-address=0.0.0.0
```

# addons
Addons aktiviert: storage-provisioner, default-storageclass, ingress (nginx).

```
minikube addons disable metrics-server
minikube addons enable ingress
minikube addons enable storage-provisioner
minikube addons enable default-storageclass
minikube addons list
```


# ingress dns
Add to /etc/hosts
```
ip=$(minikube ip)
domain="minikube.zd"
echo "
# minikube kube-prometheus
$ip	grafana.$domain
$ip	alertmanager.$domain
$ip	prometheus.$domain
"
```

# cleanup
```
docker system prune -a
minikube ssh -- docker system prune -a
```
