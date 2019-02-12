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
              port: 5555,
              protocol: "TCP",
              targetPort: 5555,
            },
          ],
          selector: labels,
          type: "LoadBalancer",
          sessionAffinity: "ClientIP"
        },
      },

      modelPersistentVolumeClaim(name, namespace, pvcSize, labels={ app: name }): {
        kind: "PersistentVolumeClaim",
        apiVersion: "v1",
        metadata: {
          labels: labels,
          name: name,
          namespace: namespace,
        },
        spec: {
          accessModes: [
            "ReadWriteOnce",
          ],
          volumeMode: "Filesystem",
          resources: {
            requests: {
              storage: pvcSize + "Gi",
            },
          },
        },
      },

      modelServer(name, namespace, memory, cpu, pvcName, configMapName, modelServerImage, licenseLocation, mojoLocation, labels={ app: name },):
        local volume = {
          name: "local-data",
          namespace: namespace,
          emptyDir: {},
        };
        base(name, namespace, memory, cpu, pvcName, configMapName, modelServerImage, licenseLocation, mojoLocation, labels),

      local base(name, namespace, memory, cpu, pvcName, configMapName, modelServerImage, licenseLocation, mojoLocation, labels) =
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
                    ] + if configMapName != "null" then [
                      {
                        name: "DRIVERLESS_AI_LICENSE_FILE",
                        value: "/config/license.sig"
                      }
                    ] else [],
                    ports: [
                      {
                        containerPort: 5555,
                        protocol: "TCP"
                      },
                    ],
                    command: [
                      "/bin/bash",
                    ],
                    args: [
                      "-c",
                      "./mojo-startup.sh " + licenseLocation + " " + mojoLocation + " " + memory,
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
                        mountPath: "/tmp",
                        name: pvcName + "-pvc",
                      }
                    ] + if configMapName != "null" then [
                      {
                        mountPath: "/config",
                        name: "mojo-configmap-" + configMapName
                      }
                    ] else [],
                    stdin: true,
                    tty: true,
                  },
                ],
                volumes: [
                  {
                    name: pvcName + "-pvc",
                    persistentVolumeClaim: {
                      claimName: pvcName,
                    },
                  },
                ] + if configMapName != "null" then [
                  {
                    name: "mojo-configmap-" + configMapName,
                    configMap: {
                      name: configMapName,
                    },
                  }
                ] else [],
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
