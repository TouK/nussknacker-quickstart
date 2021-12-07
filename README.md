[![Build status](https://github.com/touk/nussknacker-quickstart/workflows/CI/badge.svg)](https://github.com/touk/nussknacker-quickstart/actions?query=workflow%3A%22CI%22)

# Nussknacker Quickstart

This is a part of Nussknacker's [quickstart](https://nussknacker.io/quickstart/docker).
On this page you can find information about how to start work with Nussknacker designer tool.
If you want to start your own project using Nussknacker, just fork this repo, change `./conf/nusskacker/nussknacker.conf`,
register own schemas (similar to those available at `./testData/schema`) and start designing own scenarios!

## Running

Just run:
```bash
./start.sh
``` 

After doing it, you can will have available:
* [Nussknacker](http://localhost:8081/) - user/password: admin/admin
* [Apache Flink UI](http://localhost:8081/flink/)
* [Grafana](http://localhost:8081/grafana/)
* [AKHQ](http://localhost:8081/akhq/)

## What's next?

More advanced usages of Nussknacker image (available properties and so on) you can find out on our [Installation guide](https://docs.nussknacker.io/docs/next/installation_configuration_guide/Installation)

### Contributing

Please send your feedback on our [mailing list](https://groups.google.com/g/nussknacker).
Issues and pull request can be reported on our [project page](https://github.com/TouK/nussknacker)

NOTE: There are two significant branches in this repository:
- `main` should be run with latest __stable__ Nussknacker version (`latest` tag). PRs to this branch should be mainly fixes to quickstart itself.
- `staging` should be run with `staging-latest` Nussknacker version. Changes after incompatible changes in unreleased NU should be in PRs to this branch.
CI runs tests on PRs to those branches with respective Nussknacke versions.