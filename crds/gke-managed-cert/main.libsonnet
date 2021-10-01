local c = import '../../common/common.libsonnet';

{
  default(name, domains)::
    assert std.isArray(domains);
    assert std.length(domains) > 0;

    c.apiVersion('networking.gke.io/v1')
    + { kind: 'ManagedCertificate' }
    + c.metadata.new(name)
    + {
      spec: {
        domains: domains,
      },
    },
}
