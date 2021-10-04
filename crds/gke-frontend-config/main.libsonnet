local c = import '../../common/common.libsonnet';

{
  default(name, sslPolicyName='mansa-ssl-policy', redirectToHttps=true, ns=null)::
    assert sslPolicyName != null;

    c.apiVersion('networking.gke.io/v1beta1')
    + c.kind('FrontendConfig')
    + c.metadata.new(name, ns)
    + {
      spec: {
        sslPolicy: sslPolicyName,
      }
    }
    + (if redirectToHttps == true then {
      spec+: {
        redirectToHttps: {
          enabled: true,
          responseCodeName: 'MOVED_PERMANENTLY_DEFAULT',
        },
      },
    } else {}),
}
