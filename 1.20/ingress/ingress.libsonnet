local c = import '../../common/common.libsonnet';

// paths must be a list of objects like :
// {
//   route: string,
//   svcName: string,
//   svcPort: string|number,
//   routeType: string (optional),
// }
{
  gce(name, domain, paths, ip, ns=null, certName=null)::
    local fixedPaths = std.map(function(p) p { routeType: 'ImplementationSpecific' }, paths);

    c.apiVersion('networking.k8s.io/v1')
    + c.kind('Ingress')
    + c.metadata.new(
      name,
      ns,
      annotations={
        'kubernetes.io/ingress.class': 'gce',
        'kubernetes.io/ingress.global-static-ip-name': ip,
        'networking.gke.io/managed-certificates': certName,
      }
    )
    + {
      spec: $.spec(domain, fixedPaths),
    },

  nginx(name, domain, paths, clusterIssuer='letsencrypt-production', ns=null, tls=true)::
    c.apiVersion('networking.k8s.io/v1')
    + c.kind('Ingress')
    + c.metadata.new(
      name,
      ns,
      annotations={
        'cert-manager.io/cluster-issuer': clusterIssuer,
        'kubernetes.io/tls-acme': 'true',
        'kubernetes.io/ingress.class': 'nginx',
      }
    )
    + {
      spec: $.spec(domain, paths, name + '-cert'),
    },

  spec(domain, paths, secretName=null)::
    assert std.length(paths) > 0;
    assert std.objectHas(paths[0], 'route');
    assert std.objectHas(paths[0], 'svcName');
    assert std.objectHas(paths[0], 'svcPort');
    {
      [
      if secretName != null then 'tls' else null]: [
        {
          hosts: [domain],
          secretName: secretName,
        },
      ],
      rules: [
        {
          host: domain,
          http: {
            paths:
              [
                $.path(
                  p.route,
                  p.svcName,
                  p.svcPort,
                  (if std.objectHas(p, 'routeType') then p.routeType),
                )
                for p in paths
              ],
          },
        },
      ],
    },

  path(route, svcName, svcPort, type='Prefix')::
    local _type = if type == null then 'Prefix' else type;
    {
      path: route,
      pathType: _type,
      backend: {
        service: {
          name: svcName,
          port: (
            if std.isNumber(svcPort)
            then { number: svcPort }
            else { name: svcPort }
          ),
        },
      },
    },
}
