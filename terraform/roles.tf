
resource "nexus_security_role" "create_role" {
  for_each = merge(local.users_role, var.teams)

  roleid = each.key
  name = each.key
  description = each.value.description

  privileges = flatten([ 
    for role, privileges in local.access_per_role : [
      for priv in privileges : [
        for access in priv.permission : 
          "nx-repository-view-${priv.format}-${priv.repository}-${access}"
      ]
    ]
    if role == each.key
  ])

  depends_on = [ nexus_repository_docker_hosted.name ]
}

resource "nexus_security_role" "base-role" {
  name = "nx-base-role"
  roleid = "nx-base-role"
  description = "Base role for all users"
  privileges = ["nx-userschangepw"]
}

locals {
  users_role = {for key, value in var.users : value.userid => {
    roleid = value.userid
    users = ["${value.userid}"]
    description = "Pesonal team of user ${value.userid}"
  }}

  _docker_access = flatten([
    for key, value in var.docker_repository : [
      for role, permission in value.access : {
        role = role
        permission = permission
        repository = key
        format = "docker"
      }
    ]
  ])

  all_access = concat(local._docker_access)

  access_per_role = {
    for privilege in local.all_access : privilege.role => {
      repository = privilege.repository
      format = privilege.format
      permission = coalesce(  # if / else if / else
        privilege.permission == "read" ? ["read", "browse"] : null, 
        privilege.permission == "write" ? ["read", "edit", "add" , "delete", "browse"] : null,
        []
      )
    }...
  }
}