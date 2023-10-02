output "region" {
    description = "aws region"
    value = var.region
}

output "random" {
    description = "random value"
    value = random_string.suffix
}

output "cluster_name" {
    description = "cluster name"
    value = local.cluster_name
}

output "private_subnet_ids" {
    description = "subnet_ids"
    value = module.vpc.private_subnets
}

output "public_subnet_ids" {
    description = "subnet_ids"
    value = module.vpc.public_subnets
}