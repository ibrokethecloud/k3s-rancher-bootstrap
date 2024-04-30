#!/bin/sh
echo "Installing K3S"
curl  -sfL https://get.k3s.io  | INSTALL_K3S_CHANNEL="v1.27" sh -

echo "Downlading cert-manager CRDs"
wget -q -P /var/lib/rancher/k3s/server/manifests/ https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml

cat > /var/lib/rancher/k3s/server/manifests/rancher.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: cattle-system
---
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
  labels:
    certmanager.k8s.io/disable-validation: "true"
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cert-manager
  namespace: kube-system
spec:
  targetNamespace: cert-manager
  repo: https://charts.jetstack.io
  chart: cert-manager
  version: v1.5.1
  helmVersion: v3
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: rancher
  namespace: kube-system
spec:
  targetNamespace: cattle-system
  repo: https://releases.rancher.com/server-charts/stable/
  chart: rancher
  version: v2.8.1
  set:
    ingress.tls.source: rancher
    hostname: rancher.ibrokethe.cloud
    replicas: 1
    global.cattle.psp.enabled: "false"
    bootstrapPassword: password1234
  helmVersion: v3
EOF

echo "Rancher should be booted up in a few mins"
