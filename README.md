[![Build status](https://github.com/touk/nussknacker-quickstart/workflows/CI/badge.svg)](https://github.com/touk/nussknacker-quickstart/actions?query=workflow%3A%22CI%22)

# Nussknacker Quickstart


## About

This repo contains quick start showcases for [Nussknacker](https://nussknacker.io), a visual tool to define and run real-time decision algorithms. Nussknacker repo can be found [here](https://github.com/TouK/nussknacker).

&nbsp;
## Quickstart documentation

Quickstart documentation can be found at Nussknacker's documentation site:
 * [Streaming | Lite Engine](https://nussknacker.io/documentation/quickstart/lite-streaming/)
 * [Streaming | Flink Engine](https://nussknacker.io/documentation/quickstart/flink/)
 * [Request Response | Lite Engine](https://nussknacker.io/documentation/quickstart/lite-request-response/)

&nbsp;
## What's next?

[Installation guide](https://nussknacker.io/documentation/docs/installation_configuration_guide/Installation/) contains detailed information on how to adapt Nussknacker configuration to your particular needs. 

&nbsp;
### Contributing

Please send your feedback on our [mailing list](https://groups.google.com/g/nussknacker).
Issues and pull requests can be reported on our [project page](https://github.com/TouK/nussknacker).

NOTE: There are two important branches in this repository:
- `main` should be run with the latest __stable__ Nussknacker version (`latest` tag). PRs to this branch should be mainly fixes to quickstart itself.
- `staging` should be run with environment variable: NUSSKNACKER_VERSION=staging-latest.
Modifications after incompatible changes in an unreleased Nussknacker should be in PRs to this branch.

CI runs tests on PRs to those branches with respective Nussknacker versions.
