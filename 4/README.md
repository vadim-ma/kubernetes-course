https://minikube.sigs.k8s.io/docs/handbook/accessing/

после развертывания порт 31200 слушает ip из сети кубера

нужно хитрить:
    minikube ip -> 192.168.49.2
    ssh -L 31200:192.168.49.2:31200 minikube
    http://localhost:31200
или
    kubectl port-forward --address 0.0.0.0 service/short-app-port 3000:3000