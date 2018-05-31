// @apiVersion 0.1
// @name io.ksonnet.pkg.driverless
// @description Driverless AI on Kubeflow
// @shortDescription Driverless AI
// @param name string Name to give each of the components
// @param model_server_image string opsh2oai/h2oai-runtime
// @optionalParam namespace string default namespace
// @optionalParam memory string 1 memory allocated for deployment
// @optionalParam cpu string 1 number of cpu allocated for deployment
// @optionalParam gpu number 0 number of gpu allocated for deployment

local k = import 'k.libsonnet';
local driverlessai = import 'h2o-kubeflow/driverless/driverless.libsonnet';

local name = import 'param://name';
local namespace = import 'param://namespace';
local memory = import 'param://memory';
local cpu = import 'param://cpu';
local gpu = import 'param://gpu';
local modelServerImage = import 'param://model_server_image';

std.prune(k.core.v1.list.new([
  driverlessai.parts.deployment.modelServer(name, namespace, memory, cpu, gpu, modelServerImage),
  driverlessai.parts.deployment.modelService(name, namespace),
]))
