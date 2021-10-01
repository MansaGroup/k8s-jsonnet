local c = import '../../common/common.libsonnet';

{
  managedCertificate(name, domain, ns=null)::
    c.apiVersion('networking.gke.io/v1')
    + c.kind('ManagedCertificate')
    + c.metadata.new(name, ns)
    + {
      spec: {
        domains: [domain]
      },
    },
}
