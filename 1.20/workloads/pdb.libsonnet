local c = import '../../common/common.libsonnet';

{
  default(name, minAvailable=null, maxUnavailable=null, ns=null)::
    assert minAvailable != null || maxUnavailable != null;

    c.apiVersion('policy/v1beta1')
    + c.kind('PodDisruptionBudget')
    + c.metadata.new(name, ns)
    + {
      spec: {
        minAvailable: minAvailable,
        maxUnavailable: maxUnavailable,
        selector: {
          matchLabels: {
            app: name,
          },
        },
      },
    },
}
