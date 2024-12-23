# Fetch available availability zones in the region
data "aws_availability_zones" "available" {
    state = "available"
}

# Local variable to store availability zone names
locals {
    asz = data.aws_availability_zones.available.names
}

# Create a VPC
resource "aws_vpc" "custom_vpc_01" {
    cidr_block              = var.vpc_cidr
    enable_dns_hostnames    = true
    enable_dns_support      = true

    tags = {
        Name = "custom_vpc_01"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "Demo_internet_gateway" {
    vpc_id                  = aws_vpc.custom_vpc_01.id

    tags = {
        Name                = "sc_igw"
    }
}

# Create a public route table
resource "aws_route_table" "Demo_public_rt" {
    vpc_id                  = aws_vpc.custom_vpc_01.id
    
    tags = {
        Name                = "Demo_public_rt"
    }
}

# Default route for public route table
resource "aws_route" "default_route" {
    route_table_id          = aws_route_table.Demo_public_rt.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.Demo_internet_gateway.id
}

# Public Subnets
resource "aws_subnet" "Demo_public_subnet" {
    vpc_id                  = aws_vpc.custom_vpc_01.id
    count                   = length(var.public_cidrs)
    cidr_block              = var.public_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone       = local.asz[count.index]
    tags = {
        Name                = "Demo_public_subnet - ${count.index + 1}"
    }
}

# Private Subnets
resource "aws_subnet" "Demo_private_subnet" {
    vpc_id                  = aws_vpc.custom_vpc_01.id
    count                   = length(var.private_cidrs)
    cidr_block              = var.private_cidrs[count.index]
    availability_zone       = local.asz[count.index]
    tags = {
        Name                = "Demo_private_subnet - ${count.index + 1}"
    }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "Demo_public_assoc" {
    count                   = length(var.public_cidrs)
    subnet_id               = aws_subnet.Demo_public_subnet[count.index].id
    route_table_id          = aws_route_table.Demo_public_rt.id
}

# Create a security group for public instances
resource "aws_security_group" "Demo_sg" {
    name                    = "public_Demo"
    description             = "Security group for public Allows TLS inbound traffic and all outbound traffic"
    vpc_id                  = aws_vpc.custom_vpc_01.id

    tags = {
        Name                = "public_sg"
    }
}

# Ingress rule for SSH and port 3000 (Grafana/web service)
resource "aws_security_group_rule" "ingress_ssh_3000" {
    type                    = "ingress"
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
    security_group_id       = aws_security_group.Demo_sg.id
}

resource "aws_security_group_rule" "ingress_http" {
    type                    = "ingress"
    from_port               = 3000
    to_port                 = 3000
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
    security_group_id       = aws_security_group.Demo_sg.id
}

# Egress rule to allow all outbound traffic
resource "aws_security_group_rule" "egress_all" {
    type                    = "egress"
    from_port               = 0
    to_port                 = 65535
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
    security_group_id       = aws_security_group.Demo_sg.id
}


resource "aws_instance" "Demo_main_instance" {
    count                  = 1
    instance_type          = "t2.micro"
    ami                    = data.aws_ami.server_ami.id
    vpc_security_group_ids = [aws_security_group.Demo_sg.id]
    subnet_id              = aws_subnet.Demo_public_subnet[count.index].id
    key_name               = aws_key_pair.Demo_auth.id

    root_block_device {
        volume_size         = var.main_vol_size
    }

    provisioner "local-exec" {
        command = <<EOT
            # Wait until the instance is up and running
            aws ec2 wait instance-status-ok --instance-ids ${self.id} --region eu-central-1
            # Update the aws_hosts file
            if [ ! -f /home/marshal/Desktop/DevOps/Infrastructure_Terraform/aws_host ]; then
            echo '[main]' > /home/marshal/Desktop/DevOps/Infrastructure_Terraform/aws_host
            fi
            echo '${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/marshal/.ssh/id_rsa' >> /home/marshal/Desktop/DevOps/Infrastructure_Terraform/aws_host
            # Run the Ansible playbook
            ansible-playbook -i /home/marshal/Desktop/DevOps/Infrastructure_Terraform/aws_host /home/marshal/Desktop/DevOps/Infrastructure_Terraform/playbooks/main-playbook.yml
        EOT
    }

    provisioner "local-exec" {
        when                = destroy
        command             = "sed -i '/${self.public_ip}/d' /home/marshal/Desktop/DevOps/Infrastructure_Terraform/aws_host"
    }

    tags = {
        Name                = "Demo_main_instance"
    }
}


# # EC2 instance
# resource "aws_instance" "Demo_main_instance" {
#     count                  = 1
#     instance_type          = "t2.micro"
#     ami                    = data.aws_ami.server_ami.id
#     vpc_security_group_ids = [aws_security_group.Demo_sg.id]
#     subnet_id              = aws_subnet.Demo_public_subnet[count.index].id
#     key_name               = aws_key_pair.Demo_auth.id

#     root_block_device {
#         volume_size         = var.main_vol_size
#     }

#     provisioner "local-exec" {
#         command             = "printf '[main]\n${self.public_ip}' >> aws_hosts && aws ec2 wait instance-status-ok --instance-ids ${self.id} --region us-east-1"
#     }

#     provisioner "local-exec" {
#         when                = destroy
#         command             = "sed -i 'd' aws_hosts"
#     }

#     tags = {
#         Name                = "Demo_main_instance"
#     }
# }


# # Ansible playbook execution
# resource "null_resource" "main-playbook" {
#     depends_on              = [aws_instance.Demo_main_instance]

#     provisioner "local-exec" {
#         command             = "ansible-playbook -i /home/marshal/Desktop/DevOps/Terraform/aws_host /home/marshal/Desktop/DevOps/Terraform/playbooks/main-playbook.yml"

#     }
# }



# SSH key pair
resource "aws_key_pair" "Demo_auth" {
    key_name                = var.key_name
    public_key              = file(var.public_key_path)
}

# Outputs
output "grafana_access" {
    value                   = {for i in aws_instance.Demo_main_instance[*] : i.tags.Name => "${i.public_ip}:3000"}
}

# get AMI id
data "aws_ami" "server_ami" {
    most_recent              = true
    owners                   = ["099720109477"]

    filter {
    name                     = "name"
    values                   = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20241109"]
    }
}
