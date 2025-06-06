ROLE_ARN=$(cat /role)
SESSION_NAME="admin-session"

CREDENTIALS_JSON=$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "$SESSION_NAME" --output json)

export AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS_JSON" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS_JSON" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDENTIALS_JSON" | jq -r '.Credentials.SessionToken')

kubectl delete -f https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/main/utils/terraform-as-pod/deploy.yaml --ignore-not-found
kubectl delete -f https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/main/utils/terraform-as-pod/${1}_config.yaml --ignore-not-found


kubectl apply -f https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/main/utils/terraform-as-pod/${1}_config.yaml
kubectl apply -f https://raw.githubusercontent.com/danielfarag/iti-eks-gitops-capstone/main/utils/terraform-as-pod/deploy.yaml