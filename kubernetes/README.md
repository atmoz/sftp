# K8s

Example on how to setup 
if setting up for prod run `./scripts/keygen.sh` to create new keys and replace whats in secret-host-keys.yml

kubectl create namespace sftp
kubectl create -f secret-user-conf.yml
kubectl create -f secret-host-keys.yml
kubectl create -f sftp-deploy.yml

clean up
kubectl delete secret sftp-user-conf --namespace=sftp || true
kubectl delete secret sftp-host-keys --namespace=sftp || true
kubectl delete service sftp --namespace=sftp || true
kubectl delete deployment sftp --namespace=sftp || true