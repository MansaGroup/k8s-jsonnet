{
  deps(k):: {
    default(name, image, port=3000, replicas=null, domain=null, ns=null)::
      {
        deploy: k.deploy.default(name, image, port, replicas=replicas, ns=ns),
        svc: k.svc.default(name, [k.svc.port(port)], ns=ns),
        sa: k.sa.default(name, ns=ns),
      }

      + (if replicas == null then { hpa: k.hpa.default(name, ns=ns) } else {})

      + (if domain != null
         then { ingress: k.ingress.nginx(name, domain, [{ route: '/', svcName: name, svcPort: port }], ns=ns) }
         else {}),
  },
}
