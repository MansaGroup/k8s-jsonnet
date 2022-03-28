local k = import '../../1.21/main.libsonnet';

{
  // gsaEmail stands for Google Service Account Email
  addCloudSQLEnv(gsaEmail, dbName, schema='public')::
    assert dbName != null;

    {
      env+: [
        {
          name: 'DATABASE_HOST',
          value: '127.0.0.1',
        },
        {
          name: 'DATABASE_PORT',
          value: '5432',
        },
        {
          name: 'DATABASE_USERNAME',
          value: std.strReplace(gsaEmail, '.gserviceaccount.com', ''),
        },
        {
          name: 'DATABASE_PASSWORD',
          value: 'dummy_password',
        },
        {
          name: 'DATABASE_NAME',
          value: dbName,
        },
        {
          name: 'DATABASE_SCHEMA',
          value: schema,
        },
      ],
    },

  // connectionName below is displayed in the GCP console.
  // it takes the form :
  // <project_id>:<region>:<db_name>
  injectCloudSQLSidecar(connectionName)::
    assert connectionName != null;

    {
      spec+: {
        template+: {
          spec+: {
            containers+: [$.renderCloudSQLSidecarContainer(connectionName)],
          },
        },
      },
    },

  renderCloudSQLSidecarContainer(connectionName)::
    assert connectionName != null;

    k.container.spec(
      name='cloudsql-proxy',
      image='gcr.io/cloudsql-docker/gce-proxy:1.28.1-alpine',
      port=null
    )
    + {
      command: [
        '/cloud_sql_proxy',
        '--enable_iam_login',
        std.format('--instances=%s=tcp:5432', connectionName),
      ],
      resources: {
        limits: {
          cpu: '300m',
          memory: '500Gi',
        },
        requests: {
          cpu: '100m',
          memory: '200Mi',
        },
      },
      livenessProbe:: {},
      readinessProbe:: {},
    },
}
