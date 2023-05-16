terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}
resource "docker_container" "example" {
  name  = "mycontainer"
  image = "nginx"
  ports {
    internal = 80
    external = 8080
  }
}