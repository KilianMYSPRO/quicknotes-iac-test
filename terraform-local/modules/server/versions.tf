# Un module doit declarer les providers "non hashicorp" qu'il utilise,
# sinon Terraform cherche hashicorp/docker (qui n'existe pas).
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
