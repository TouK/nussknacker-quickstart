[![Build status](https://github.com/touk/nussknacker-quickstart/workflows/CI/badge.svg)](https://github.com/touk/nussknacker-quickstart/actions?query=workflow%3A%22CI%22)

# Nussknacker Quickstart

This is a part of Nussknacker's [quickstart](https://nussknacker.io/quickstart/docker).
On this page you can find information about how to start work with Nussknacker Designer tool.
If you want to start your own project using Nussknacker, just fork this repo, adjust configuration,
register own schemas (similar to those available at `./common/schemas`) and start designing own scenarios!

Available modes:
- `docker-compose` based (for Flink runtime)
- Kubernetes and helm based (for streaming-lite runtime)

## Running docker mode

Just run:
```bash
./docker/start.sh
``` 

After doing it, you can will have available:
* [Nussknacker](http://localhost:8081/) - user/password: admin/admin
* [Apache Flink UI](http://localhost:8081/flink/)
* [Grafana](http://localhost:8081/grafana/)
* [AKHQ](http://localhost:8081/akhq/)

## Running kubernetes + helm mode mode

We assume that you have configured `kubectl` and `helm`. 

### Local K3d installation
If you don't have K8s available, we recommend installing [k3d](https://k3d.io/).
Instructions below assume that cluster was created with ingress port mapped to 8081 - see [guide](https://k3d.io/v5.0.0/usage/exposing_services/#1-via-ingress-recommended) for details.

### Installation

First, set `RELEASE` environment variable, e.g to `nu-quickstart`, which will be used as Helm release name. It's also needed for test data scripts. 

By default, we assume that the quickstart is installed on local k8s installation with port 8081 mapped for ingress (see e.g. k3d setup above).
If you install quickstart on cluster with public domain available, set `DOMAIN` variable to your domain, see also `k8s-helm/values.yaml` for more ingress configuration (e.g. certificate management).

Afterwards, just run:
```bash
./k8s-helm/install.sh
``` 

After doing it, you can will have available:
* [Nussknacker](http://localhost:8081/) - user/password: admin/admin
* [Grafana](http://localhost:8081/grafana/)
* [AKHQ](http://localhost:8081/akhq/)
If you've set `DOMAIN` environment variable, replace `http://localhost:8081` with `http(s)://$RELEASE-nussknacker.$DOMAIN/` in above links. 


## What's next?

More advanced usages of Nussknacker image (available properties and so on) you can find out on our [Installation guide](https://docs.nussknacker.io/docs/next/installation_configuration_guide/Installation)

### Contributing

Please send your feedback on our [mailing list](https://groups.google.com/g/nussknacker).
Issues and pull request can be reported on our [project page](https://github.com/TouK/nussknacker)

NOTE: There are two significant branches in this repository:
- `main` should be run with latest __stable__ Nussknacker version (`latest` tag). PRs to this branch should be mainly fixes to quickstart itself.
- `staging` should be run with `staging-latest` Nussknacker version. Changes after incompatible changes in unreleased NU should be in PRs to this branch.
CI runs tests on PRs to those branches with respective Nussknacke versions.