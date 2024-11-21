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

## Running Tilt

```shell
tilt up
```

## Running Jupyter lab locally with all NaaVRE extensions

It is sometimes useful to run a standalone development version of Jupyter Lab
with all NaaVRE extensions installed and configured to connect to the other
services running in Tilt.

### Initial setup

```shell
virtualenv venv
. venv/bin/activate
pip install 'jupyterlab>=4.0.0'
. venv/bin/activate
find services/jupyterlab/extensions -mindepth 1 -maxdepth 1 -type d | while read ext_dir; do
  pip install -e "$ext_dir"
  jupyter labextension develop "$ext_dir" --overwrite
done
jupyter labextension list
```

The output of the last command should contain several extensions starting with
`@naavre/` under `NaaVRE-dev-integration/venv/share/jupyter/labextensions`.

### Usage

Generate environment variables. This includes OAuth tokens, so we must make sure that the `keycloak` service is running in Tilt. Run the commands below, and check the contents of `dev.env`. It should contain values for `OAUTH_ACCESS_TOKEN` and `OAUTH_REFRESH_TOKEN`.

```shell
cat << EOF > dev.env
NAAVRE_ALLOWED_DOMAINS=naavre-dev.minikube.test
VRE_API_VERIFY_SSL=false
EOF
curl -k "https://naavre-dev.minikube.test/auth/realms/vre/protocol/openid-connect/token" -d "grant_type=password" -d "username=user" -d "password=user" -d "client_id=naavre" -d "client_secret=fake_openid_client_secret" | jq '"OAUTH_ACCESS_TOKEN="+.access_token + "\nOAUTH_REFRESH_TOKEN=" + .refresh_token' -r >> dev.env
```

Start the dev server. Run the commands below, or add a corresponding run configuration to your IDE.

```shell
. venv/bin/activate
while read env; do export $env; done < dev.env
python -m jupyterlab.labapp --watch --log-level=0
```

If see authentication errors when trying to communicate with NaaVRE services, re-generate the environment variables and restart the dev server.

To rebuild an extension after changing its code, run the commands below and reload the page in your browser.

```shell
. venv/bin/activate
cd services/jupyterlab/extensions/NaaVRE-foobar-jupyterlab
jlpm build
```
