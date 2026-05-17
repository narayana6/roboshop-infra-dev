resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  //public_key = file("~/.ssh/eks.pub")
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7qnfuZVmOe/o6caHxARmzaK86As299RNKaCzU/2tfV/E8BzjslYcVfjH0Et4H/7wgGkwNrj+Xj0PDSJC3sXRl9+ZpZLLIaH3NPLNNrJBGPuqisYvW7bLIUiImrlQCBV0jJZYLS3xvBSvZB4O+lFLosEeWj7dlat4hirUHfMyFP6JTCslVYUb4ZJ7DfpxasObsq9Nz8pLeriEH4ZL6oImRj+i5usoJMKa1O+6Rs0f9eUv3aGSnO51udQjo5hlpM3npKvW78u1gIdOq5rfSlS2SnxGOkYNOsjqIJH4ZgnlJOO6BcQpt5tXmUcqwDxV95e8QRxH6R8GhiIgjK0q9BV/cmPxRnQUJeJjIXemsfN8VhHjV/FyYBChrH27zB9DeTMO+P6zyHsLw5J2OhqQSpT2f3WZnmzI0Xqz1z7hJe4NUFE0kGPjyu4BMo441g2HR2asOEcewc32r6MN6aHzQZetPtOX44YKIJTQmTbgL3DMySFm8rNvni2s3ImDyrN/mwygjz3tF3BvwU9+0P43EcuvmljTRpSVQE0svzijeLcc2qGQqFM99OENVzGypKVkj+A8d+nIKWRmGMfcb7180lpHm5AtZHC3klFB5xBix8yU4By1yEonkkSUw99hrMZU+RG++cmCztAKCtuCW2Pu3YuCEkrwjbrqRP53w0iuAfhxgYw== Harshitha@DESKTOP-FVC6L0K"
  # ~ means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.33"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = data.aws_ssm_parameter.vpc_id.value
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  create_cluster_security_group = false
  cluster_security_group_id     = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large","t3.small"]
  }

  eks_managed_node_groups = {
        blue = {
        min_size      = 3
        max_size      = 10
        desired_size  = 3
        capacity_type = "SPOT"
        iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
       }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
       key_name = aws_key_pair.eks.key_name
     } 
  #    green = {
  #     min_size      = 3
  #     max_size      = 10
  #     desired_size  = 3
  #     capacity_type = "SPOT"
  #     iam_role_additional_policies = {
  #       AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  #       AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  #       ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  #     }
  #     # EKS takes AWS Linux 2 as it's OS to the nodes
  #     key_name = aws_key_pair.eks.key_name
  #   }
  # }
  }
  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = var.common_tags


  
}
