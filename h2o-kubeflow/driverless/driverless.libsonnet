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
              port: 12345,
              protocol: "TCP",
              targetPort: 12345,
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

      modelServer(name, namespace, memory, cpu, gpu, modelServerImage, labels={ app: name } ):
        local volume = {
          name: "local-data",
          namespace: namespace,
          emptyDir: {},
        };
        base(name, namespace, memory, cpu, gpu, modelServerImage, labels),

      local base(name, namespace, memory, cpu, gpu, modelServerImage, labels) =
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
                    securityContext: {
                      privileged: true,
                    },
                    ports: [
                      {
                        containerPort: 12345,
                        protocol: "TCP",
                      },
                    ],
                    env: [
                      {
                        name: "DAI_START_COMMAND",
                        value: "if nvidia-smi | grep -o failed || true; then ./run.sh; else nvidia-smi -pm 1 && ./run.sh; fi",
                      },
                    ],
                    command: [
                      "/bin/bash",
                    ],
                    args: [
                      "-c",
                      "$(DAI_START_COMMAND)",
                    ],
                    resources: {
                      requests: {
                        memory: memory + "Gi",
                        cpu: cpu,
                        "nvidia.com/gpu": gpu,
                      },
                      limits: {
                        memory: memory + "Gi",
                        cpu: cpu,
                        "nvidia.com/gpu": gpu,
                      },
                    },
                    volumeMounts: [
                      {
                        mountPath: "/tmp",
                        name: "dai-pvc",
                      },
                      {
                        mountPath: "/log",
                        name: "dai-pvc",
                      },
                      {
                        mountPath: "/license",
                        name: "dai-pvc"
                      }
                    ],
                  },
                ],
                volumes: [
                  {
                    name: "dai-pvc",
                    persistentVolumeClaim: {
                      claimName: name,
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
