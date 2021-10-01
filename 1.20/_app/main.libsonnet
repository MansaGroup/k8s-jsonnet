local managedCert = import '../../crds/gke-managed-certificate/main.libsonnet';

{
  deps(k):: {
    default(name, image, port=3000, replicas=null, domain=null, ingressStaticIp=null, ns=null)::
      {
        deployment: k.deployment.default(name, image, port, replicas=replicas, ns=ns),
        svc: k.svc.default(name, [k.svc.port(port)], ns=ns),
      }

      + (if replicas == null then { hpa: k.hpa.default(name, ns=ns) } else {})

      + (if domain != null
         then {
           cert: managedCert.managedCertificate(name, domain, ns=ns),
           ingress: k.ingress.default(name, domain, ingressStaticIp, [{ route: '/', svcName: name, svcPort: port }], ns=ns),
         }
         else {}),
  },
}
