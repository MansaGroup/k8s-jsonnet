local k = import '../1.21/main.libsonnet';

std.objectValues(
  k._app.default(
    'appName',
    'appImage:v1.0',
    domain='myapp.voodoo.io',
    ns='my-hardcoded-ns'
  ),
)
