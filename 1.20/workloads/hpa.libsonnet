local c = import '../../common/common.libsonnet';

{
  default(name, resources=[], maxReplicas=5, ns=null)::
    c.apiVersion('autoscaling/v2beta2')
    + c.kind('HorizontalPodAutoscaler')
    + c.metadata.new(name, ns)
    + {
      spec: {
        scaleTargetRef: {
          apiVersion: 'apps/v1',
          kind: 'Deployment',
          name: name,
        },
        minReplicas: 1,
        maxReplicas: maxReplicas,
        metrics:
          if resources != []
          then resources
          else
            [
              $.resource('memory', 90),  // this is based on the request, not the limit
              $.resource('cpu', 90),
            ],
      },
    },

  resource(name, averageUtilization):: {
    type: 'Resource',
    resource: {
      name: name,
      target: {
        type: 'Utilization',
        averageUtilization: averageUtilization,
      },
    },
  },
}
