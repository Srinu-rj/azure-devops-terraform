variable "environments" {
  description = ""
  type = map(object({
    location= string
    tag_env= string
  }))

  default = {
    dev={}
    qa={}
    prod={}
  }
}