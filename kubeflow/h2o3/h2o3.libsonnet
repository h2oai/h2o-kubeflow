local k = import 'k.libsonnet';
local deployment = k.extensions.v1beta1.deployment;
local container = deployment.mixin.spec.template.spec.containersType;
local storageClass = k.storage.v1beta1.storageClass;
local service = k.core.v1.service;
local networkPolicy = k.extensions.v1beta1.networkPolicy;
local networkSpec = networkPolicy.mixin.spec;


{
  parts:: {
    deployment:: {
      local defaults = {
        imagePullPolicy:: "IfNotPresent",
        resources:: {
          requests: {
            memory: "1Gi",
            cpu: "1",
          },
          limits: {
            memory: "16Gi",
            cpu: "4",
          },
        },
      },

      modelService(name, namespace, labels={ app: name }): {
        apiVersion: "v1",
        kind: "Service",
        metadata: {
          labels: labels,
          name: name,
          namespace: namespace,
        },
        spec: {
          ports: [
            {
              port: 54321,
              protocol: "TCP",
              targetPort: 54321,
            },
          ],
          selector: labels,
          type: "LoadBalancer",
        },
      },

      modelServer(name, namespace, modelServerImage, labels={ app: name } ):
        local volume = {
          name: "local-data",
          namespace: namespace,
          emptyDir: {},
        };
        base(name, namespace, modelServerImage, labels),

      local base(name, namespace, modelServerImage, labels) =
        {
          apiVersion: "extensions/v1beta1",
          kind: "Deployment",
          metadata: {
            name: name,
            namespace: namespace,
            labels: labels,
          },
          spec: {
            strategy: {
                rollingUpdate: {
                    maxSurge: 1,
                    maxUnavailable: 1
                },
                type: "RollingUpdate"
            },
            template: {
              metadata: {
                labels: labels,
              },
              spec: {
                containers: [
                  {
                    name: name,
                    image: modelServerImage,
                    imagePullPolicy: defaults.imagePullPolicy,
                    env: [],
                    ports: [
                      {
                        containerPort: 54321,
                        protocol: "TCP"
                      },
                    ],
                    workingDir: "/opt",
                    command: [
                      "java",
                      "-Xmx1g",
                      "-jar",
                      "h2o.jar"
                    ],
                    resources: {},
                    stdin: true,
                    tty: true,
                  },
                ],
                dnsPolicy: "ClusterFirst",
                restartPolicy: "Always",
                schedulerName: "default-scheduler",
                securityContext: {},
              },
            },
          },
        },
    },
  },
}
