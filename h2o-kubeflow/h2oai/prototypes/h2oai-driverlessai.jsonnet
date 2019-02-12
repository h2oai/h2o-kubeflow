// @apiVersion 0.1
// @name io.ksonnet.pkg.h2oai-driverlessai
// @description Driverless AI on Kubeflow
// @shortDescription Driverless AI
// @param name string Name to give each of the components
// @param model_server_image string opsh2oai/h2oai-runtime
// @optionalParam namespace string default namespace
// @optionalParam memory string 1 memory allocated for deployment
// @optionalParam cpu string 1 number of cpu allocated for deployment
// @optionalParam gpu number 0 number of gpu allocated for deployment
// @optionalParam pvcSize number 50 size of persistent volume claim for deployment
// @optionalParam configMapName string null name of optional configmap containing any user config files wished to be include. Expects at least config.toml and license.sig

local k = import 'k.libsonnet';
local driverlessai = import 'h2o-kubeflow/h2oai/h2oai-driverlessai.libsonnet';

local name = import 'param://name';
local namespace = import 'param://namespace';
local configmapname = import 'param://configMapName';
local memory = import 'param://memory';
local cpu = import 'param://cpu';
local gpu = import 'param://gpu';
local pvcSize = import 'param://pvcSize';
local modelServerImage = import 'param://model_server_image';

std.prune(k.core.v1.list.new([
  driverlessai.parts.deployment.modelServer(name, namespace, configmapname, memory, cpu, gpu, modelServerImage),
  driverlessai.parts.deployment.modelService(name, namespace),
  driverlessai.parts.deployment.modelPersistentVolumeClaim(name, namespace, pvcSize),
]))
