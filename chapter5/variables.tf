
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
  default     = "management"
}

variable "author" {
  type        = string
  description = "Created by"
  default = "Timothy Onoja"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets_count" {
  type = number
  description = "Number of public subnets"
  default = 2
}

variable "private_subnets_count" {
  type = number
  description = "Number of private subnets"
  default = 2
}

variable "bastion_instance_type" {
  type = string
  description = "Bastion instance type"
  default = "t2.micro"
}

variable "public_key" {
  type = string
  description = "SSH public key path"
  default = "./id_rsa.pub"
}

variable "jenkins_master_instance_type" {
  type = string
  description = "Jenkins master EC2 instance type"
  default = "t2.large"
}

variable "jenkins_worker_instance_type" {
  type = string
  description = "Jenkins worker EC2 instance type"
  default = "t2.medium"
}

variable "jenkins_username" {
  type = string
  description = "Jenkins admin user"
  default = "JENKINS-MASTER"
}

variable "jenkins_password" {
  type = string
  description = "Jenkins admin password"
  default = "PASSWORD"
}

variable "jenkins_credentials_id" {
  type = string
  description = "Jenkins workers SSH based credentials id"
  default = "./id_rsa"
}