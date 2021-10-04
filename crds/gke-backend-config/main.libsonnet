local c = import '../../common/common.libsonnet';

{
  default(name, iapSecretName='ss-iap-oauth-credentials', ns=null)::
    c.apiVersion('networking.gke.io/v1beta1')
    + c.kind('BackendConfig')
    + c.metadata.new(name, ns)
    + {
      spec: {},
    }
    + (if iapSecretName != null then {
      spec+: {
        iap: {
          enabled: true,
          oauthclientCredentials: {
            secretName: iapSecretName,
          },
        }
      },
    } else {}),
}
