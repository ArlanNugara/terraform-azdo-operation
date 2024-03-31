// User Entitlement

resource "azuredevops_user_entitlement" "user" {
  for_each       = var.email_address
  principal_name = each.key
}