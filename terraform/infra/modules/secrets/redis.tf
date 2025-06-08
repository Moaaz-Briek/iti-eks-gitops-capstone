resource "aws_secretsmanager_secret" "redis_credentials" {
  name = "redis-credentials"
}

resource "aws_secretsmanager_secret_version" "redis_credentials_version" {
  secret_id = aws_secretsmanager_secret.redis_credentials.id
  secret_string = jsonencode({
    REDIS_HOST = var.REDIS_HOST  
    REDIS_PASSWORD = var.REDIS_PASSWORD  
    REDIS_DB = var.REDIS_DB
  })
}