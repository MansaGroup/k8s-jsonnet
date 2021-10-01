local k120 = import '../1.20/main.libsonnet';

k120 {
  pod: (import './workload/pod.libsonnet').deps(self),
}
