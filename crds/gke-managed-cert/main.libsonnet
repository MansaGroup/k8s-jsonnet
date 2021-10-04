local c = import '../../common/common.libsonnet';

{
  default(name, domains, ns=null)::
    assert std.isArray(domains);
    assert std.length(domains) > 0;

    c.apiVersion('networking.gke.io/v1')
    + c.kind('ManagedCertificate')
    + c.metadata.new(name, ns)
    + {
      spec: {
        domains: domains,
      },
    },
}
