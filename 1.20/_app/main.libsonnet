{
  deps(k):: {
    default(name, image, port=3000, replicas=null, domain=null, ingressIp=null, ns=null)::
      assert domain == null || ingressIp != null;
      {
        deploy: k.deploy.default(name, image, port, replicas=replicas, ns=ns),
        svc: k.svc.default(name, [k.svc.port(port)], ns=ns, type=(if domain != null then 'NodePort' else 'ClusterIP')),
        sa: k.sa.default(name, ns=ns),
      }

      + (if replicas == null then { hpa: k.hpa.default(name, ns=ns) } else {})

      + (if domain != null then {
        ingress: k.ingress.gce(name, domain, [{ route: '/*', svcName: name, svcPort: port }], ip=ingressIp, ns=ns)
      } else {}),
  },
}
