locals {
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

# Creates a new empty file system in EFS.
resource "aws_efs_file_system" "kubernetes_shared_storage" {
  tags = {
    Name = "kubernetes_shared_storage"
    Owner = "jonico"
  }
}

# Creates a mount target of EFS in a specified subnet
# such that our instances can connect to it.
resource "aws_efs_mount_target" "kubernetes_storage_mount_point" {
  file_system_id  = aws_efs_file_system.kubernetes_shared_storage.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
  count = 3
}

# Allows both ingress and eggress for port 2049 (nfs)
# such that our instances are able to get to the mount
# target in the AZ.
resource "aws_security_group" "efs" {
  name        = "efs-mnt"
  description = "Allows NFS traffic from instances within the VPC."
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = local.cidr_blocks
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = local.cidr_blocks
  }

  tags = {
    Name = "allow_nfs-ec2"
  }
}
