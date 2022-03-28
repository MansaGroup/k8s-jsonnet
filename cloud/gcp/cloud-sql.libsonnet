local k = import '../../1.21/main.libsonnet';

{
  // gsaEmail stands for Google Service Account Email
  injectEnv(gsaEmail, dbName, schema='public')::
    assert dbName != null;

    {
      env+: [
        {
          name: 'POSTGRESQL_HOST',
          value: '127.0.0.1',
        },
        {
          name: 'POSTGRESQL_PORT',
          value: '5432',
        },
        {
          name: 'POSTGRESQL_USERNAME',
          value: std.strReplace(gsaEmail, '.gserviceaccount.com', ''),
        },
        {
          name: 'POSTGRESQL_PASSWORD',
          value: 'not_used_but_must_be_present',
        },
        {
          name: 'POSTGRESQL_DB_NAME',
          value: dbName,
        },
        {
          name: 'POSTGRESQL_DB_SCHEMA',
          value: schema,
        },
      ],
    },

  // connectionName below is displayed in the GCP console.
  // it takes the form :
  // <project_id>:<region>:<db_name>
  injectSidecar(connectionName)::
    assert connectionName != null;

    {
      spec+: {
        template+: {
          spec+: {
            containers+: [$.renderSidecar(connectionName)],
          },
        },
      },
    },

  renderSidecar(connectionName)::
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
          memory: '500Mi',
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
