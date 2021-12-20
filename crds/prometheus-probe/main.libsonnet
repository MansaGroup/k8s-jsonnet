local c = import '../../common/common.libsonnet';

{
  default(name, interval="30s", module="http_2xx", prober="blackbox-exporter.monitoring.svc.cluster.local:19115", targets, ns=null)::
    assert std.isArray(targets);
    assert std.length(targets) > 0;

    c.apiVersion('monitoring.coreos.com/v1')
    + c.kind('Probe')
    + c.metadata.new(name)
    + {
      spec: {
        interval: interval,
        module: module,
        prober: {
          url: prober,
        },
        targets: {
          staticConfig: {
            static: targets,
          },
        },
      },
    },
}
