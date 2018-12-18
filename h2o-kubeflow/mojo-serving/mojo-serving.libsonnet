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
              port: 8080,
              protocol: "TCP",
              targetPort: 8080,
            },
          ],
          selector: labels,
          type: "LoadBalancer",
          sessionAffinity: "ClientIP"
        },
      },

      modelServer(name, namespace, memory, cpu, pvcName, modelServerImage, licenseLocation, mojoLocation, labels={ app: name },):
        local volume = {
          name: "local-data",
          namespace: namespace,
          emptyDir: {},
        };
        base(name, namespace, memory, cpu, pvcName, modelServerImage, licenseLocation, mojoLocation, labels),

      local base(name, namespace, memory, cpu, pvcName, modelServerImage, licenseLocation, mojoLocation, labels) =
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
                    env: [
                      {
                        name: "MEMORY",
                        value: memory,
                      },
                      {
                        name: "DEP_NAME",
                        value: name
                      }
                    ],
                    ports: [
                      {
                        containerPort: 8080,
                        protocol: "TCP"
                      },
                    ],
                    command: [
                      "/bin/bash",
                    ],
                    args: [
                      "-c",
                      "./mojo-startup.sh " + licenseLocation + " " + mojoLocation,
                    ],
                    workingDir: "/",
                    resources: {
                      requests: {
                        memory: memory + "Gi",
                        cpu: cpu,
                      },
                      limits: {
                        memory: memory + "Gi",
                        cpu: cpu,
                      },
                    },
                    volumeMounts: [
                      {
                        mountPath: "/mojo-models",
                        name: name + "-pvc",
                      }
                    ],
                    stdin: true,
                    tty: true,
                  },
                ],
                volumes: [
                  {
                    name: name + "-pvc",
                    persistentVolumeClaim: {
                      claimName: pvcName,
                    },
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
