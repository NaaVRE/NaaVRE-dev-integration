k8s_yaml(helm(
  './helm-chart/',
  name='jupyterlab-standalone',
  values=[
    './helm-values.yaml',
    ],
  ))

k8s_resource(
  'jupyterlab-standalone',
  labels=['NaaVRE-jupyter'],
  links=['https://naavre-dev.minikube.test/jupyterlab-standalone/'],
  trigger_mode=TRIGGER_MODE_MANUAL,
  )
