local c = import '../../common/common.libsonnet';

{
  default(name, minAvailable=null, maxUnavailable=null, ns=null)::
    assert minAvailable != null || maxUnavailable != null;

    c.apiVersion('policy/v1beta1')
    + c.kind('PodDisruptionBudget')
    + c.metadata.new(name, ns)
    + {
      spec: {
        selector: {
          matchLabels: {
            app: name,
          },
        },
      },
    }
    + if minAvailable != null then {
      spec+: {
        minAvailable: minAvailable,
      }
    } else {
      spec+: {
        maxUnavailable: maxUnavailable,
      }
    },
}
