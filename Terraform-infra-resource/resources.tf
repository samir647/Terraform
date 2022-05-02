

# EC2 Instance
resource "aws_instance" "myec2vm" {
  subnet_id = aws_subnet.publicSubnet.id
  ami = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  availability_zone = var.avail_zone
  key_name = var.instance_keypair
  vpc_security_group_ids = [ aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id   ]

  tags = {
    "Name" = "EC2 Demo 2"
  }

}


resource "aws_eip" "internetface"{
  instance = aws_instance.myec2vm.id
  vpc = true
} 
