6.2
minikube start
. <(kubectl completion bash)
kubectl get all
kubectl delete deployments.apps short-app-deployment 
kubectl delete services short-app-port 

kubectl apply -f app-service.yaml service/short-app-clusterip created
kubectl apply -f app-deployment.yaml deployment.apps/short-app-deployment created
kubectl get all

6.3
6.4
mminikube addons list
minikube addons enable ingress
6.5
kubectl apply -f ingress.yaml
kubectl get ingress

NODE_PORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
sudo apt update
sudo apt install -y socat
MINIKUBE_IP=$(minikube ip)
sudo socat TCP-LISTEN:80,fork,reuseaddr TCP:${MINIKUBE_IP}:${NODE_PORT} &