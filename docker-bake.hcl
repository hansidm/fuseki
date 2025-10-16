group "all" {
  targets = [
    "fuseki-5-5-0",
    "fuseki-5-6-0",
  ]
}

group "default" {
  targets = [
    "fuseki-5-6-0",
  ]
}

target "fuseki-5-5-0" {
  context    = "."
  dockerfile = "Dockerfile-5.5.0"
  tags = [
    "hansidm/fuseki:5.5.0",
    "hansidm/fuseki:latest",
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}

target "fuseki-5-6-0" {
  context    = "."
  dockerfile = "Dockerfile-5.6.0"
  tags = [
    "hansidm/fuseki:5.6.0",
    "hansidm/fuseki:latest",
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
