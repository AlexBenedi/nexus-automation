

resource "nexus_security_user" "create" {
  for_each = var.users

  userid    = each.value.userid
  firstname = each.value.firstname
  lastname  = each.value.lastname
  email     = each.value.email
  password  = each.value.password
  roles     = ["nx-admin"]
  status    = each.value.status
}

resource "nexus_security_role" "create_role" {
  for_each = var.teams

  roleid = each.key
  name = each.key
}