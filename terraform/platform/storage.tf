resource "kubernetes_manifest" "ebs_csi" {
  manifest = yamldecode(file("${path.module}/manifests/storage-class.yaml"))
}