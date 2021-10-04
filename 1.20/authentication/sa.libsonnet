local c = import '../../common/common.libsonnet';

{
  default(name, ns=null)::
    c.apiVersion('v1')
    + c.kind('ServiceAccount')
    + c.metadata.new(name, ns),
}
