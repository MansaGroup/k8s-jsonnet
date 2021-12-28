local c = import '../../common/common.libsonnet';

// paths must be a list of objects like :
// {
//   route: string,
//   svcName: string,
//   svcPort: string|number,
//   routeType: string (optional),
// }
{
  gce(name, domain, paths, ipName, certName=null, ns=null)::
    local fixedPaths = std.map(function(p) p { routeType: 'ImplementationSpecific' }, paths);

    c.apiVersion('networking.k8s.io/v1')
    + c.kind('Ingress')
    + c.metadata.new(
      name,
      ns,
      annotations={
        'kubernetes.io/ingress.class': 'gce',
        'kubernetes.io/ingress.global-static-ip-name': ipName,
      } + (if certName != null then { 'networking.gke.io/managed-certificates': certName } else {})
    )
    + {
      spec: $.spec(domain, fixedPaths),
    },

  gceMany(name, defaultServiceName, defaultServicePort, domainsAndPaths, ipName, certName=null, ns=null)::
    $.gce(name, '', [], ipName, certName, ns)
    + {
      spec+: {
        defaultBackend: {
          service: {
            name: defaultServiceName,
            port: {
              number: defaultServicePort,
            },
          },
        },
        rules: std.flattenArrays(
          std.objectValues({
            [x.domain]: $.spec(x.domain, std.map(function(p) p { routeType: 'ImplementationSpecific' }, x.paths)).rules
            for x in domainsAndPaths
          }),
        ),
      },
    },

  nginx(name, domain, paths, ingressClass='nginx', clusterIssuer='letsencrypt-production', ns=null)::
    local secretName = if clusterIssuer != null then name + 'cert' else null;

    c.apiVersion('networking.k8s.io/v1')
    + c.kind('Ingress')
    + c.metadata.new(
      name,
      ns,
      annotations={
        'kubernetes.io/ingress.class': ingressClass,
      } + (if clusterIssuer != null then {
        'cert-manager.io/cluster-issuer': clusterIssuer,
        'kubernetes.io/tls-acme': 'true',
      } else {}),
    )
    + {
      spec: $.spec(domain, paths, secretName),
    },

  nginxMany(name, defaultServiceName, defaultServicePort, domainsAndPaths, ingressClass='nginx', clusterIssuer='letsencrypt-production', ns=null)::
    $.nginx(name, '', [], ingressClass, clusterIssuer, ns)
    + {
      spec+: {
        defaultBackend: {
          service: {
            name: defaultServiceName,
            port: {
              number: defaultServicePort,
            },
          },
        },
        rules: std.flattenArrays(
          std.objectValues({
            [x.domain]: $.spec(x.domain, x.paths).rules
            for x in domainsAndPaths
          }),
        ),
      },
    },

  spec(domain, paths, secretName=null)::
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
    assert route != null;
    assert svcName != null;
    assert svcPort != null;

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
