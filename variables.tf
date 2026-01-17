variable "bucket_name" {
    default = "hostingthefirststaticweb"
  
}


variable "primary" {
  type = string
  default = "ap-south-1"
}


variable "secondary" {
  type = string
  default = "us-east-1"
}


variable "primary_vpc_cidr" {
  default = "10.0.0.0/16"

  
}


variable "secondary_vpc_cidr" {
  default = "10.1.0.0/16"
  
}



variable "primary_subnet_cidr" {
  default = "10.0.1.0/24"
  
}




variable "secondary_subnet_cidr" {
  default = "10.1.1.0/24"
  
}





variable "instance_type" {
  default = "t3.micro"
}


variable "primary_key_name" {
  default = "vpc-peering-demo"
  
}


variable "secondary_kay_name" {
  default = "vpc-peering-demo-us"
}





