local c = import '../../common/common.libsonnet';

{
  deps(k):: {
    local pod = self,

    default(name, image, port=null)::
      c.apiVersion('v1')
      + c.kind('Pod')
      + c.metadata.new(name)
      + {
        spec: pod.spec(name, image, port),
      },

    spec(name, image, port)::
      {
        serviceAccountName: name,
        securityContext: {
          runAsUser: 1000,
          runAsGroup: 3000,
          fsGroup: 2000,
          runAsNonRoot: true,
        },
        containers: [
          k.container.spec(name, image, port),
        ],
      },

    utils:: {
      removeAllSecurityContexts():: {
        spec+: {
          securityContext:: {},
          containers: [
            x { securityContext:: {} }
            for x in super.containers
          ],
        },
      },

      removeAllProbes():: {
        spec+: {
          containers: [
            x {
              readinessProbe:: {},
              livenessProbe:: {},
            }
            for x in super.containers
          ],
        },
      },

      setResourceLimit(rsName, rsValue, containerName=null):: setResource('limits', rsName, rsValue, containerName),
      setResourceRequest(rsName, rsValue, containerName=null):: setResource('requests', rsName, rsValue, containerName),

      local setResource(reqLim, name, value, containerName) = {
        spec+: {
          containers: [
            if containerName == null || containerName == x.name
            then x {
              resources+: {
                [reqLim]+: { [name]: value },
              },
            }
            else x
            for x in super.containers
          ],
        },
      },

      updateContainer(containerName, container):: {
        spec+: {
          containers: [
            if x.name == containerName
            then x + container
            else x
            for x in super.containers
          ],
        },
      },
    },
  },
}
