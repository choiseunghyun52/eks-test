locals {
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  region          = "ap-northeast-2"
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  tag = {
    Environment = "test"
    Terraform   = "true"
  }
}

module "eks" {
  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.0"

  # Cluster Name Setting
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  # Cluster Endpoint Setting
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  # Network Setting
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnets

  # IRSA Enable / OIDC 구성
  enable_irsa = true

  node_security_group_additional_rules = {
    ingress_nodes_karpenter_port = {
      description                   = "Cluster API to Node group for Karpenter webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  # Tag Node Security Group
  node_security_group_tags = {
    "karpenter.sh/discovery" = local.cluster_name
  }

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.large"]
      create_security_group = false
      create_launch_template = false     # do not remove
      launch_template_name = ""          # do not remove

      min_size     = 2
      max_size     = 3
      desired_size = 2

      iam_role_additional_policies = [
        # Required by Karpenter
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }
  }

  # console identity mapping (AWS user)
  # eks configmap aws-auth에 콘솔 사용자 혹은 역할을 등록
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::750132647424:user/seunghyun.choi"
      username = "seunghyun.choi"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "750132647424"
  ]
}