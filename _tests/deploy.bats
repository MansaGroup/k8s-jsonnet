load ../helpers.bats

@test "== deploy tests (all k8s versions) ==" {}
for v in "${!k8s[@]}"
do
  @test "deploy: minimal - rendering" {
    m=$($gen "${k8s[$v]}.deploy.default('name', 'image:v1', 8080)")
    jq_test "$m" '.kind' 'Deployment'
  }

  @test "deploy: minimal - kubeval" {
    $gen "${k8s[$v]}.deploy.default('name', 'image:v1', 8080)" | $kubeval
  }

  @test "deploy: minimal - polaris" {
    $gen "${k8s[$v]}.deploy.default('name', 'image:v1', 8080)" | $polaris
  }

  @test "deploy: complete - rendering" {
    m=$($gen "${k8s[$v]}.deploy.default('name', 'image:v1', 8080, replicas=12, ns='my-ns')")

    echo $m | kubeval
    jq_test "$m" '.metadata.namespace' 'my-ns'
    jq_test "$m" '.spec.replicas' '12'
  }

  @test "deploy: resource updates" {
    m_orig="${k8s[$v]}.deploy.default('name', 'image:v1', 8080)"
    jq_test "$($gen $m_orig)" '.spec.template.spec.containers[0].resources.requests.cpu' '100m'
    jq_test "$($gen $m_orig)" '.spec.template.spec.containers[0].resources.limits.cpu' '200m'

    m_cpu_req=$($gen "$m_orig + ${k8s[$v]}.deploy.utils.setResourceRequest('cpu', 'new_cpu_req')")
    jq_test "$m_cpu_req" '.spec.template.spec.containers[0].resources.requests.cpu' 'new_cpu_req'
    jq_test "$m_cpu_req" '.spec.template.spec.containers[0].resources.limits.cpu' '200m'

    m_cpu_lim=$($gen "$m_orig + ${k8s[$v]}.deploy.utils.setResourceLimit('cpu', 'new_cpu_limit')")
    jq_test "$m_cpu_lim" '.spec.template.spec.containers[0].resources.requests.cpu' '100m'
    jq_test "$m_cpu_lim" '.spec.template.spec.containers[0].resources.limits.cpu' 'new_cpu_limit'
  }
done

