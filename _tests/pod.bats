load ../helpers.bats

@test "== pod tests (all k8s versions) ==" {}
for v in "${!k8s[@]}"
do
  @test "pod: minimal - rendering" {
    $gen "${k8s[$v]}.pod.default('name', 'image:v1', 8000)" >/dev/null
  }

  @test "pod: minimal - kubeval" {
    $gen "${k8s[$v]}.pod.default('name', 'image:v1', 8000)" | $kubeval
  }

  @test "pod: minimal - polaris" {
    $gen "${k8s[$v]}.pod.default('name', 'image:v1', 8000)" | $polaris
  }

  @test "pod: resource updates" {
    m_orig="${k8s[$v]}.pod.default('name', 'image:v1', 8080)"
    jq_test "$($gen $m_orig)" '.spec.containers[0].resources.requests.cpu' '100m'
    jq_test "$($gen $m_orig)" '.spec.containers[0].resources.limits.cpu' '200m'

    m_cpu_req=$($gen "$m_orig + ${k8s[$v]}.pod.utils.setResourceRequest('cpu', 'new_cpu_req')")
    jq_test "$m_cpu_req" '.spec.containers[0].resources.requests.cpu' 'new_cpu_req'
    jq_test "$m_cpu_req" '.spec.containers[0].resources.limits.cpu' '200m'

    m_cpu_lim=$($gen "$m_orig + ${k8s[$v]}.pod.utils.setResourceLimit('cpu', 'new_cpu_limit')")
    jq_test "$m_cpu_lim" '.spec.containers[0].resources.requests.cpu' '100m'
    jq_test "$m_cpu_lim" '.spec.containers[0].resources.limits.cpu' 'new_cpu_limit'
  }
done
