# Cluster ID
output "cluster_id" {
  value = module.eks.cluster_id
}

# Cluster endpoint
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}