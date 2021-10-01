load ../helpers.bats

@test "== ingress tests (all k8s versions) ==" {}

for v in "${!k8s[@]}"
do
  @test "ingress: nginx - rendering" {
    m=$($gen "${k8s[$v]}.ingress.nginx('name', 'domain.com', [{route: '/', svcName: 'my-svc', svcPort: 8080}])")

    jq_test "$m" '.spec.rules[0].http.paths[0].backend.service.port.number' '8080'
  }

  @test "ingress: nginx - rendering port name" {
    m=$($gen "${k8s[$v]}.ingress.nginx('name', 'domain.com', [{route: '/', svcName: 'my-svc', svcPort: 'http', routeType: 'Exact'}])")

    jq_test "$m" '.spec.rules[0].http.paths[0].backend.service.port.name' 'http'
  }

  @test "ingress: nginx - kubeval" {
    $gen "${k8s[$v]}.ingress.nginx('name', 'domain.com', [{route: '/', svcName: 'my-svc', svcPort: 8080}])" | $kubeval
  }

  @test "ingress: nginx - rendering complete" {
    m=$($gen "${k8s[$v]}.ingress.nginx('name', 'domain.com', [{route: '/', svcName: 'my-svc', svcPort: 8080}], ns='ns')")

    jq_test "$m" '.metadata.namespace' 'ns'
  }

  @test "ingress: gce - rendering complete" {
    m=$($gen "${k8s[$v]}.ingress.gce('name', 'domain.com', [{route: '/', svcName: 'my-svc', svcPort: 8080}], 'global-ip', ns='ns', certName='certName')")

    jq_test "$m" '.metadata.namespace' 'ns'
    jq_test "$m" '.metadata.annotations["kubernetes.io/ingress.global-static-ip-name"]' 'global-ip'
    jq_test "$m" '.metadata.annotations["networking.gke.io/managed-certificates"]' 'certName'
    jq_test "$m" '.spec.tls' 'null'
    jq_test "$m" '.spec.rules[0].http.paths[0].pathType' 'ImplementationSpecific'
  }
done
