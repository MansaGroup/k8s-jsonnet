local c = import '../../common/common.libsonnet';

{
  managedCertificate(appName, domain)::
    c.apiVersion('networking.gke.io/v1')
    + { kind: 'ManagedCertificate' }
    + c.metadata.new(appName)
    + {
      spec: {
        domains: [domain]
      },
    },
}
