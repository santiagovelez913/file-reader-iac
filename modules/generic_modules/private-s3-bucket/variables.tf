variable "bucket_name" {
  type        = string
}
variable "environment" {
  type        = string
}
variable "allowed_roles_arns" {
  type        = set(string)
}