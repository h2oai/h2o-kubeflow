// @apiVersion 0.1
// @name io.ksonnet.pkg.driverless
// @description Driverless AI on Kubeflow
// @shortDescription Driverless AI
// @param name string Name to give each of the components
// @param model_server_image string opsh2oai/h2oai-runtime
// @optionalParam namespace string default namespace

local k = import 'k.libsonnet';
local driverlessai = import 'kubeflow/driverless/driverless.libsonnet';

local name = import 'param://name';
local namespace = import 'param://namespace';
local modelServerImage = import 'param://model_server_image';

std.prune(k.core.v1.list.new([
  driverlessai.parts.deployment.modelServer(name, namespace, modelServerImage),
  driverlessai.parts.deployment.modelService(namespace, name),
]))
