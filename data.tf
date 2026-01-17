data "aws_availability_zones" "primary" { 
    provider = aws.primary
    state = "available" 

}


data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state = "available"
}




data "aws_ami" "primary_ami" {
  most_recent = true
  provider = aws.primary

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical


  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}







data "aws_ami" "secondary_ami" {
  most_recent = true
  provider = aws.secondary

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical


  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}