# NaaVRE-dev-integration

Integrated development environment for NaaVRE.

OS support:

- ✅ Linux (tested on Ubuntu 22.04 and Arch Linux)
- ❌ Windows (user report: some conda packages cannot be installed)
- ❌ WSL2 (user report: Minikube ingress DNS does not work)
- ❔ macOS

## Initial setup

*Run these steps once, when setting up the environment.*

### Clone the git repository

To integrate the different components of NaaVRE, we use Git submodules:

```shell
git clone --recurse-submodules git@github.com:QCDIS/NaaVRE-dev-integration.git
```

If you get an error:

```
Cloning into 'NaaVRE-dev-environment'...
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

then you need to add your ssh key to your GitHub account. Follow the instructions [here](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account).

Check out the [Git Submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

### Conda environment

Install Conda from these instructions: https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html

Setup a new conda environment and install dependencies:

```shell
cd NaaVRE-dev-environment
conda env create -n naavre-dev --file environment.yml
conda activate naavre-dev
```

### Helm charts dependencies

Run:

```shell
helm dependency build services/NaaVRE-catalogue-service/NaaVRE-catalogue-service/helm/naavre-catalogue-service
```

### GitHub repository for building cells

To containerize cells from this dev environment, you need to set up a personal GitHub repository. It will be used to commit the cells code and build and publish the container images:

1. Create your repository from the [QCDIS/NaaVRE-cells](https://github.com/QCDIS/NaaVRE-cells) template, and follow instructions from its README file to generate an access token.
2. Add the following values to [./services/NaaVRE-containerizer-service/helm-values-local.yaml](./services/NaaVRE-containerizer-service/helm-values-local.yaml):

```yaml
env:
  CELL_GITHUB: "https://github.com/my-org/my-naavre-cells-repo.git"
  CELL_GITHUB_TOKEN: "github_pat_..."
```

### Minikube cluster

The NaaVRE component are deployed by tilt to a minikube cluster. To start the minikube cluster, run:

```shell
minikube start --addons=ingress,ingress-dns
```

This uses the [ingress-dns](https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns/) addon to expose services through a local domain name (we use `naavre-dev.minikube.test`).
After starting minikube, you need to configure your operating system to resolve this domain name to the IP of the minikube cluster. This IP is obtained by running `minikube ip`.
There are two options:
- Configure your OS to use the minikube DNS for resolving all `.test` domain. Follow the [ingress-dns](https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns/) documentation. (This is the most flexible, but can be challenging to setup.)
- Configure your OS to resolve `naavre-dev.minikube.test` to the IP of minikube. (This is all you need to run NaaVRE in this environment, and is easier to setup.)

  1. Get the minikube IP
     ```console
     $ minikube ip
     192.168.49.2
     ```

  2. Add the following line to `/etc/hosts` (replace the IP with the output of step 1):
     ```
     192.168.49.2 naavre-dev.minikube.test
     ```

To stop the cluster, run:

```shell
minikube stop
```

To reset it:

```shell
minikube delete
```

## Running Tilt

*If you haven’t done so already, [start the minikube](#minikube-cluster).*

```shell
tilt up
```

### Connecting the workflow-service to Argo

To connect the workflow-service to Argo workflows:

- Retrieve the argo token by running
  ```shell
  kubectl get secret vre-api.service-account-token -o=jsonpath='{.data.token}' | base64 --decode
  ```
- Create a file `./services/NaaVRE-workflow-service/helm-values-local.yaml` with the following content (replace `TOKEN` with the output of the above command):
  ```yaml
  conf:
    virtual_labs_configuration:
      rawJson: |
        {
          "vl_configurations": [
            {
              "name": "test-virtual-lab-1",
              "wf_engine_config": {
                "name": "argo",
                "api_endpoint": "https://naavre-dev.minikube.test/argowf/",
                "access_token": "TOKEN",
                "service_account": "executor",
                "namespace": "default",
                "workdir_storage_size": "1Gi"
              }
            }
          ]
        }
  ```
- Reload the `(Tiltfile)` resource in Tilt.

## Running Jupyter lab locally with all NaaVRE extensions

It is sometimes useful to run a standalone development version of Jupyter Lab
with all NaaVRE extensions installed and configured to connect to the other
services running in Tilt.
If you do not need to do iterative development of the Jupyter Lab extensions, you can skip this step.

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

If you get authentication errors when trying to communicate with NaaVRE services, re-generate the environment variables and restart the dev server.

To rebuild an extension after changing its code, run the commands below and reload the page in your browser.

```shell
. venv/bin/activate
cd services/jupyterlab/extensions/NaaVRE-foobar-jupyterlab
jlpm build
```
