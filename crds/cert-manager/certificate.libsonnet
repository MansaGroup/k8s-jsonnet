local c = import '../../common/common.libsonnet';

{
  default(name, dnsNames, secretName=null, issuerKind="ClusterIssuer", issuerName="letsencrypt-production", ns)::
    assert name != null;
    assert dnsNames != null;
    assert issuerKind != null;
    assert issuerName != null;

    local defSecretName = if secretName != null then secretName else std.format('%s-tls', name);

    c.apiVersion('cert-manager.io/v1')
    + c.kind('Certificate')
    + c.metadata.new(name, ns)
    + {
      spec: {
        secretName: defSecretName,
        issuerRef: {
          kind: issuerKind,
          name: issuerName,
        },
        dnsNames: dnsNames,
      },
    },
}
