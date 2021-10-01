local c = import '../../common/common.libsonnet';

// paths must be a list of objects with keys :
// route(string), svcName(string), svcPort(string|number), routeType(optional, string)
{
  default(name, domain, staticIp, paths, ns=null)::
    assert domain != null;
    assert staticIp != null;
    assert std.length(paths) > 0;
    assert std.objectHas(paths[0], 'route');
    assert std.objectHas(paths[0], 'svcName');
    assert std.objectHas(paths[0], 'svcPort');

    c.apiVersion('networking.k8s.io/v1')
    + c.kind('Ingress')
    + c.metadata.new(
      name,
      ns,
      annotations={
        'networking.gke.io/managed-certificates': name,
        'kubernetes.io/ingress.global-static-ip-name': staticIp,
      }
    )
    + {
      spec: {
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
    },

  path(route, svcName, svcPort, type='ImplementationSpecific')::
    local _type = if type == null then 'ImplementationSpecific' else type;
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
