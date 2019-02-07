// @apiVersion 0.1
// @name io.ksonnet.pkg.h2oai-h2o3
// @description H2O3 on Kubeflow
// @shortDescription H2O3 Static Cluster
// @param name string Name to give each of the components
// @param model_server_image string gcr.io/h2o-gce/h2o3
// @optionalParam namespace string default namespace
// @optionalParam memory string 1 starting memory per pod
// @optionalParam cpu string 1 starting number of cpu per pod
// @optionalParam replicas number 1 starting number of pods

local k = import 'k.libsonnet';
local h2o3static = import 'h2o-kubeflow/h2oai/h2oai-h2o3.libsonnet';

local name = import 'param://name';
local namespace = import 'param://namespace';
local memory = import 'param://memory';
local cpu = import 'param://cpu';
local replicas = import 'param://replicas';
local modelServerImage = import 'param://model_server_image';


std.prune(k.core.v1.list.new([
  h2o3static.parts.deployment.modelServer(name, namespace, memory, cpu, replicas, modelServerImage),
  h2o3static.parts.deployment.modelService(name, namespace),
]))
