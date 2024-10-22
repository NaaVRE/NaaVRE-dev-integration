load('../../helpers.Tiltfile', 'get_custom_build_command')

naavre_dev_sync_steps = []
naavre_dev_run_steps = []
for package in [
    'NaaVRE-communicator-jupyterlab',
    'NaaVRE-containerizer-jupyterlab',
    ]:
  naavre_dev_sync_steps += [
    sync('./extensions/' + package + '/src/', '/app/dev/extensions/' + package + '/src/'),
    sync('./extensions/' + package + '/schema/', '/app/dev/extensions/' + package + '/schema/'),
    sync('./extensions/' + package + '/style/', '/app/dev/extensions/' + package + '/style/'),
    sync('./extensions/' + package + '/' + package, '/app/dev/extensions/' + package + '/' + package),
    ]
  naavre_dev_run_steps += [
    run('cd "/app/dev/extensions/' + package + '" && jlpm build', trigger=[
      './extensions/' + package + '/src/',
      './extensions/' + package + '/schema/',
      ]),
    ]

custom_build(
  'ghcr.io/naavre/naavre-jupyterlab-dev',
  get_custom_build_command(path='.', file='./docker/dev.Dockerfile'),
  [
    './docker/dev.Dockerfile',
    './extensions',
    './settings',
    ],
  skips_local_docker=True,
  disable_push=True,
  live_update=naavre_dev_sync_steps + naavre_dev_run_steps,
  )
