ROLE_ARN=$(cat /role)
SESSION_NAME="admin-session"

CREDENTIALS_JSON=$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "$SESSION_NAME" --output json)

export AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS_JSON" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS_JSON" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDENTIALS_JSON" | jq -r '.Credentials.SessionToken')

kubectl delete -f https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/feature/deploy-scripts/utils/tf_pod.yaml
kubectl delete -f https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/feature/deploy-scripts/utils/${1}_config.yaml


kubectl apply -f https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/feature/deploy-scripts/utils/${1}_config.yaml
kubectl apply -f https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/feature/deploy-scripts/utils/tf_pod.yaml