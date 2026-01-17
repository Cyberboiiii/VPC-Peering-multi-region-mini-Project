resource "aws_vpc" "primary_vpc" {
  cidr_block = var.primary_vpc_cidr
  provider = aws.primary
  enable_dns_hostnames = true
  enable_dns_support = true


  tags = {
    Name = "Primary-VPC-${var.primary}"
  }
  
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block = var.secondary_vpc_cidr
  provider = aws.secondary
  enable_dns_hostnames = true
  enable_dns_support = true


  tags = {
    Name = "Secondary-VPC-${var.secondary}"
  
  }
  
}

resource "aws_subnet" "primary_subnet" {
  provider = aws.primary
  vpc_id     = aws_vpc.primary_vpc.id
  cidr_block = var.primary_subnet_cidr
  availability_zone = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true


  tags = {
    Name = "Primary-subnet-${var.primary}"

  }
}

resource "aws_subnet" "secondary_subnet" {
  provider = aws.secondary
  vpc_id     = aws_vpc.secondary_vpc.id
  cidr_block = var.secondary_subnet_cidr
  availability_zone = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true


  tags = {
    Name = "Secondary-subnet-${var.secondary}"
    
  }
}

resource "aws_internet_gateway" "primary_gateway" {
  vpc_id = aws_vpc.primary_vpc.id
  provider = aws.primary

  tags = {
    Name = "Primary-internet-gateway-${var.primary}"
  }
}

resource "aws_internet_gateway" "secondary_gateway" {
  vpc_id = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  tags = {
    Name = "Secondary-internet-gateway-${var.secondary}"
  }
}

resource "aws_route_table" "primary_route_table" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_gateway.id
  }


  tags = {
    Name = "Primary-routetable-${var.primary}"
  }
}

resource "aws_route_table" "secondary_route_table" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_gateway.id
  }


  tags = {
    Name = "Secondary-routetable-${var.secondary}"
  }
}

resource "aws_route_table_association" "primary_rta" {
  provider = aws.primary
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_route_table.id
}

resource "aws_route_table_association" "secondary_rta" {
  provider = aws.secondary
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_route_table.id
}

resource "aws_vpc_peering_connection" "primary2secondary" {
  provider      = aws.primary
  peer_vpc_id   = aws_vpc.secondary_vpc.id
  vpc_id        = aws_vpc.primary_vpc.id
  peer_region = var.secondary
  auto_accept = false 


  tags = {
    Name = "Primary2Secondary-peeringconnection"
  }

}


# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "secondary_accepter" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id

  auto_accept               = true

  tags = {
    Side = "Secondary-Accepter"
  }
}

resource "aws_route" "primary_to_secondary" {
  provider = aws.primary
  route_table_id            = aws_route_table.primary_route_table.id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id


  depends_on = [ aws_vpc_peering_connection_accepter.secondary_accepter ]
}

resource "aws_route" "secondary2primary" {
  provider = aws.secondary

  route_table_id            = aws_route_table.secondary_route_table.id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id


  depends_on = [ aws_vpc_peering_connection_accepter.secondary_accepter ]
}


resource "aws_security_group" "primary_security_group" {
  provider = aws.primary
  name        = "primary_sg"
  description = "Security group for primary vpc instance"
  vpc_id      = aws_vpc.primary_vpc.id

  tags = {
    Name = "Primary-security-group-${var.primary}"
  }

  ingress {

    description       = "SSH from anywhere"
    from_port         = 22
    protocol          = "tcp"
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {

    description       = "ICMP from secondary VPC"
    from_port         = -1
    protocol          = "icmp"
    to_port           = -1
    cidr_blocks       = [var.secondary_vpc_cidr]
  }

  ingress {

    description       = "All traffic from Secondary VPC"
    from_port         = 0
    protocol          = "tcp"
    to_port           = 65535
    cidr_blocks       = [var.secondary_vpc_cidr]

  }

  egress {

    description       = "Allow all outbound traffic"
    from_port         = 0
    protocol          = "-1"
    to_port           = 0
    cidr_blocks       = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "secondary_security_group" {
  provider = aws.secondary
  name        = "secondary_sg"
  description = "Security group for secondary vpc instance"
  vpc_id      = aws_vpc.secondary_vpc.id

  tags = {
    Name = "Secondary-security-group-${var.secondary}"
  }

  ingress {

    description       = "SSH from anywhere"
    from_port         = 22
    protocol          = "tcp"
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {

    description       = "ICMP from primary VPC"
    from_port         = -1
    protocol          = "icmp"
    to_port           = -1
    cidr_blocks       = [var.primary_vpc_cidr]
  }

  ingress {

    description       = "All traffic from Primary VPC"
    from_port         = 0
    protocol          = "tcp"
    to_port           = 65535
    cidr_blocks       = [var.primary_vpc_cidr]

  }

  egress {

    description       = "Allow all outbound traffic"
    from_port         = 0
    protocol          = "-1"
    to_port           = 0
    cidr_blocks       = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "primary_instance" {
  provider = aws.primary
  ami           = data.aws_ami.primary_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [ aws_security_group.primary_security_group.id ]

  user_data = local.primary_user_data
  depends_on = [ aws_vpc_peering_connection_accepter.secondary_accepter ]



  tags = {
    Name = "HelloWorld"
  }
}








resource "aws_instance" "secondary_instance" {
  provider = aws.secondary
  ami           = data.aws_ami.secondary_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.secondary_subnet.id
  vpc_security_group_ids = [ aws_security_group.secondary_security_group.id ]

  user_data = local.secondary_user_data
  depends_on = [ aws_vpc_peering_connection_accepter.secondary_accepter ]



  tags = {
    Name = "HelloWorld"
  }
}

















