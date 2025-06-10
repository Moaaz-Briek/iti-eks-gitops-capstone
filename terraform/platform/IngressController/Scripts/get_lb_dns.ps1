$lb_dns = kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
$output = @{ lb_dns = $lb_dns } | ConvertTo-Json
Write-Output $output
