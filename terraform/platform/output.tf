output "storage_class" {
  value = kubernetes_manifest.ebs_csi.manifest.metadata.name
}