// @apiVersion 0.1
// @name io.ksonnet.pkg.mojo-serving
// @description H2O3 on Kubeflow
// @shortDescription H2O3 Static Cluster
// @param name string Name to give each of the components
// @param model_server_image string gcr.io/h2o-gce/h2o3
// @optionalParam namespace string default namespace
// @optionalParam memory string 1 starting memory per pod
// @optionalParam cpu string 1 starting number of cpu per pod
// @optionalParam pvc_name string driverless name of persistent volume claim containing mojo models
// @optionalParam replicas number 1 starting number of pods
// @optionalParam license_location string license.sig location of driverless ai license
// @optionalParam mojo_location string tmp directory where the mojo.zip file resides

local k = import 'k.libsonnet';
local mojoserving = import 'h2o-kubeflow/mojo-serving/mojo-serving.libsonnet';

local name = import 'param://name';
local namespace = import 'param://namespace';
local memory = import 'param://memory';
local cpu = import 'param://cpu';
local pvcName = import 'param://pvc_name';
local modelServerImage = import 'param://model_server_image';
local licenseLocation = import 'param://license_location';
local mojoLocation = import 'param://mojo_location';


std.prune(k.core.v1.list.new([
  mojoserving.parts.deployment.modelServer(name, namespace, memory, cpu, pvcName, modelServerImage, licenseLocation, mojoLocation),
  mojoserving.parts.deployment.modelService(name, namespace),
]))
