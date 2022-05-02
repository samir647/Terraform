#Variable
variable vpc_cidr_block {}
variable psubnet_cidr_block {}
variable avail_zone {}
variable public_route_cidr{}
variable sshallowed{}
variable outgoingcidr{}
variable incominghttp{}

#VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = false

  tags = { 
    Name  : "WebVPC"
    Environment : "Dev"
    Project : "WebDev"
  }
}

#SubNet

resource "aws_subnet" "publicSubnet" {
vpc_id = aws_vpc.main.id
cidr_block = var.psubnet_cidr_block
availability_zone = var.avail_zone
   tags = {
    "Environment" = "Dev"
    "Project" = "WebDev"
    "Name" = "PublicSubnet"
  }
 
}

#Internet-gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

    tags = { 
    Environment : "Dev"
    Project : "WebDev"
  }
}



#Route Tables
resource "aws_route_table" "publicRoute" {
    vpc_id = aws_vpc.main.id

    route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC internet gateway or a virtual private gateway.
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "public"
  }

}


#RouteTable association

resource "aws_route_table_association" "publicassociation" {
  # The subnet ID to create an association.
  subnet_id = aws_subnet.publicSubnet.id

  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.publicRoute.id
}


# Create Security Group - SSH Traffic
resource "aws_security_group" "vpc-ssh" {
  vpc_id = aws_vpc.main.id
  name        = "vpc-ssh"
  description = "Dev VPC SSH"
  
  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sshallowed
    }

  egress {
    description = "Allow all ip and ports outbound"    
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.outgoingcidr
  }

  tags = {
    Name = "vpc-ssh"
  }
}

# Create Security Group - Web Traffic
resource "aws_security_group" "vpc-web" {
  vpc_id = aws_vpc.main.id
  name        = "vpc-web"
  description = "Dev VPC Web"
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.incominghttp // this is just for test 
  }
  ingress {
    description = "Allow Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.incominghttp
  }  
  egress {
    description = "Allow all ip and ports outbound"    
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.outgoingcidr
  }

  tags = {
    Name = "vpc-web"
  }
}

