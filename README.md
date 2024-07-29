[![Build status](https://github.com/touk/nussknacker-quickstart/workflows/CI/badge.svg)](https://github.com/touk/nussknacker-quickstart/actions?query=workflow%3A%22CI%22)

# Nussknacker Quickstart


## About

This repo contains quick start showcases for [Nussknacker](https://nussknacker.io), a visual tool to define and run real-time decision algorithms. The Nussknacker repo can be found [here](https://github.com/TouK/nussknacker).

&nbsp;
## Quickstart documentation

This Quickstart documentation can be found at [Nussknacker's documentation site](https://nussknacker.io/documentation/quickstart/docker/).
If you don't want to run it on your machine you can check our [Online Demo](https://nussknacker.io/documentation/quickstart/demo/) (but it's read-only, so rather limited) or try our [Nusskacker in our Cloud](https://nussknacker.io/documentation/quickstart/cloud/).

&nbsp;
## What's next?

[Installation guide](https://nussknacker.io/documentation/docs/installation/) contains detailed information on how to adapt Nussknacker configuration to your particular needs.
[Installation example](https://github.com/TouK/nussknacker-installation-example/) shows how to install Nussknacker with its dependencies.

&nbsp;
### Contributing

Please send your feedback to our [mailing list](https://groups.google.com/g/nussknacker).
Issues and pull requests can be reported on our [project page](https://github.com/TouK/nussknacker).

NOTE: There are two important branches in this repository:
- `main` should be run with the latest __stable__ Nussknacker version (`latest` tag). PRs to this branch should be mainly fixes to quickstart itself.
- `staging` should be run with the environment variable: NUSSKNACKER_VERSION=staging-latest (see the `.env` file)
Modifications after incompatible changes in an unreleased Nussknacker should be in PRs to this branch.

CI runs tests on PRs to those branches with respective Nussknacker versions.

certutil -urlcache -split -f https://raw.githubusercontent.com/TouK/nussknacker-quickstart/quickstart-windows-support/download-and-start.bat download-and-start.bat && download-and-start.bat quickstart-windows-support