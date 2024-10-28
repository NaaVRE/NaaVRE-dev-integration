load('../../helpers.Tiltfile', 'get_custom_build_command')

custom_build(
  'ghcr.io/naavre/naavre-jupyterlab',
  get_custom_build_command(path='.', file='./docker/Dockerfile'),
  [
    './docker/Dockerfile',
    './extensions',
    './settings',
    ],
  skips_local_docker=True,
  disable_push=True,
  )
