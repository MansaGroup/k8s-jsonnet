{
  _app: (import './_app/main.libsonnet').deps(self),
  container: import './workload/container.libsonnet',
  deployment: (import './workload/deployment.libsonnet').deps(self),
  hpa: import './workload/hpa.libsonnet',
  ingress: import './network/ingress.libsonnet',
  pod: (import './workload/pod.libsonnet').deps(self),
  sa: import './rbac/sa.libsonnet',
  svc: import './network/service.libsonnet',
}
