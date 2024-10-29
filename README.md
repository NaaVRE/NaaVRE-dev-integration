# NaaVRE-dev-integration

> [!WARNING]
> This is a very preliminary README. Most information still needs to be migrated from https://github.com/QCDIS/NaaVRE-dev-environment/blob/main/README.md.

## Getting started

### Initial configuration

#### Cells GitHub repository

Add the following values to [./services/NaaVRE-containerizer-service/helm-values-local.yaml](./services/NaaVRE-containerizer-service/helm-values-local.yaml):

```yaml
env:
  CELL_GITHUB: "https://github.com/my-org/my-naavre-cells-repo.git"
  CELL_GITHUB_TOKEN: "github_pat_..."
```

#### Helm charts dependencies

```shell
helm dependency build services/NaaVRE-catalogue-service/NaaVRE-catalogue-service/helm/naavre-catalogue-service
```
