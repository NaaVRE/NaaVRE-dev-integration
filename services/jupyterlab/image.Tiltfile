naavre_dev_sync_steps = [
  sync('./extensions/', '/app/dev/extensions/'),
  ]
naavre_dev_run_steps = [
  run('cd "/app/dev/extensions/' + package + '" && jlpm build',
      trigger=['./extensions/' + package + '/'])
  for package in [
    'demo-auth',
    'naavre-communicator',
    ]
  ]

custom_build(
  'ghcr.io/naavre/naavre-jupyterlab-dev',
  'docker buildx build . -f ./docker/dev.Dockerfile -t $EXPECTED_REF --push',
  [
    './docker/dev.Dockerfile',
    './extensions',
    './settings',
    ],
  skips_local_docker=True,
  disable_push=True,
  live_update=naavre_dev_sync_steps + naavre_dev_run_steps,
  )
