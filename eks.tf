module "eks" {
  # eks 모듈에서 사용할 변수 정의
  source = "./modules/eks-cluster"
  cluster_name = "fast-cluster"
  cluster_version = "1.24"
  vpc_id = module.vpc.vpc_id

  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}
