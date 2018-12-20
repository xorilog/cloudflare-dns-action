# Cloudflare DNS GitHub Action

[![Build Status](https://travis-ci.org/xorilog/cloudflare-dns-action.svg?branch=master)](https://travis-ci.org/xorilog/cloudflare-dns-action)

A GitHub action to set a Cloudflare DNS record on push to the master branch. 

```hcl
workflow "on push to master, adjust domain on Cloudflare" {
  on = "push"
  resolves = ["set cloudflare dns record"]
}

action "set cloudflare dns record" {
  uses = "xorilog/cloudflare-dns-action@master"
  env = {
    RECORD_DOMAIN = "site.example.com",
    RECORD_TYPE = "A",
    RECORD_VALUE = "192.168.0.11",
    RECORD_NAME = "terraform",
    RECORD_TTL = "1",
  }
  secrets = [ "CLOUDFLARE_EMAIL", "CLOUDFLARE_TOKEN" ]
}
```

_Heavily_ inspired by [Jessie Frazelle's](https://twitter.com/jessfraz) [aws-fargate-action](https://github.com/jessfraz/aws-fargate-action) and [Chris Pilsworth](https://twitter.com/cpilsworth) [cloudflare-worker-action](https://github.com/cpilsworth/cloudflare-worker-action) GitHub action project. :trophy:

### Tests

The tests use [shellcheck](https://github.com/koalaman/shellcheck). You don't
need to install anything. They run in a container. 

```console
$ make test
```

### Using the `Makefile`

```console
$ make help
cf-apply                      Run terraform apply for Amazon.
cf-destroy                    Run terraform destroy for Amazon.
cf-plan                       Run terraform plan for Amazon.
shellcheck                     Runs the shellcheck tests on the scripts.
test                           Runs the tests on the repository.
update-terraform               Update terraform binary locally from the docker container.
update                         Update terraform binary locally.
```
