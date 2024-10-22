def get_custom_build_command(path, file):
  command = [
    'docker', 'buildx', 'build',
    path,
    '-f', file,
    '-t', '$EXPECTED_REF',
    ]
  # When using a dev VM (https://github.com/QCDIS/NaaVRE-dev-vm/), build images
  # need to be pushed to the container registry running on the VM. Tilt takes
  # care of the discovery and configuration of this registry, but we need to
  # explicitly add the --push flag.
  # On the other hand, when running Minikube locally, built images are loaded
  # directly into the docker runtime. In this case, the --push flag results
  # in an error because no container registry is involved.
  if k8s_context() == 'naavre-dev-vm':
    command.append('--push')
  return ' '.join(command)
