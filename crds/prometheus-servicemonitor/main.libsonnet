local c = import '../../common/common.libsonnet';

{
  default(name, matchLabels, port, interval="30s", ns=null)::
    assert std.isObject(matchLabels);
    assert std.length(matchLabels) > 0;

    c.apiVersion('monitoring.coreos.com/v1')
    + c.kind('ServiceMonitor')
    + c.metadata.new(name)
    + {
      spec: {
        selector: {
          matchLabels: matchLabels,
        },
        endpoints: [{
          port: port,
          interval: interval
        }],
      },
    },
}
