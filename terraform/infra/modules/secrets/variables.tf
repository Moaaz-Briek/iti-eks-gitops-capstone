variable "cluster_name"{
  type = string
}
###################### MYSQL CREDENTIALS ######################
variable "MYSQL_HOSTNAME"{
  type = string
  default = "mysql"
}

variable "MYSQL_USERNAME"{
  type = string
  default = "user"
}

variable "MYSQL_PASSWORD"{
  type = string
  default = "password"
}

variable "MYSQL_ROOT_PASSWORD"{
  type = string
  default = "password"
}

variable "MYSQL_DATABASE"{
  type = string
  default = "db"
}

###################### REDIS CREDENTIALS ######################

variable "REDIS_HOST"{
  type = string
  default = "redis"
}


variable "REDIS_PASSWORD"{
  type = string
  default = "password"
}

variable "REDIS_DB"{
  type = string
  default = "0"
}


########################## OIDC  ##########################

variable "eks_oidc_arn" {
  type = string
}