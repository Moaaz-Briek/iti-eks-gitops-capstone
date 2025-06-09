apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${name}-secret
  namespace: default
spec:
  refreshInterval: "1h"
  secretStoreRef:
    name: aws-secretsmanager-store
    kind: ClusterSecretStore
  target:
    name: ${name}-k8s-secret
    creationPolicy: Owner
  dataFrom:
    - extract:
        key: ${name}-credentials
