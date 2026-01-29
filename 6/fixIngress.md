kubectl get svc -n  ingress-nginx

EXTERNAL-IP - <pending>

---
 Способ 3: Использовать externalIPs в текущем сервисе (самый простой)
bash
# 1. Пропатчите текущий сервис
kubectl patch svc -n ingress-nginx ingress-nginx-controller \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/externalIPs", "value": ["10.129.0.29"]}]'

# 2. Или отредактируйте напрямую
kubectl edit svc -n ingress-nginx ingress-nginx-controller
# Добавьте в секцию spec:
# externalIPs:
#   - 10.129.0.29

# 3. Проверьте
kubectl get svc -n ingress-nginx


---

kubectl get svc -n  ingress-nginx -o yaml > ingress-controller.fix.yaml

# 1. Полностью пересоздаем сервис с externalIPs
kubectl delete svc -n ingress-nginx ingress-nginx-controller

# 2. Создаем новый сервис
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
spec:
  type: LoadBalancer
  externalIPs:
    - 10.129.0.29
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
EOF

# 3. Проверяем
kubectl get svc -n ingress-nginx -w