apiVersion: v1
kind: ServiceAccount
metadata:
  name: external
  namespace: external-secrets
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}
