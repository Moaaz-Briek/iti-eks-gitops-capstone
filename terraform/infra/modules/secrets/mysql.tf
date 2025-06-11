resource "aws_secretsmanager_secret" "mysql_credentials" {
  name = "mysql-credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "mysql_credentials_version" {
  secret_id = aws_secretsmanager_secret.mysql_credentials.id
  secret_string = jsonencode({
    MYSQL_HOST          = var.MYSQL_HOSTNAME  
    MYSQL_USER          = var.MYSQL_USERNAME
    MYSQL_PASSWORD      = var.MYSQL_PASSWORD
    MYSQL_ROOT_PASSWORD = var.MYSQL_ROOT_PASSWORD
    MYSQL_DATABASE      = var.MYSQL_DATABASE
  })
}
