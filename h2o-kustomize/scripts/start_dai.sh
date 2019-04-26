source kustomize_dai.common

TEMPLATE_DIR="${WORKING_DIR}/templates"
BASE_DIR="../driverlessai/base"

echo "--------------------------"
echo "Generating Startup Patches"
echo "--------------------------"

cp ${TEMPLATE_DIR}/kustomization.yaml.tmpl.base ${BASE_DIR}/kustomization.yaml
cp -r ${TEMPLATE_DIR}/*.yaml ${BASE_DIR}/patch/

for file in ../driverlessai/base/patch/*.yaml
do
  sed -i '' "s*NAMESPACE*${NAMESPACE}*g" $file
  sed -i '' "s*PVC_NAME*${PVC_NAME}*g" $file
  sed -i '' "s*NAME*${NAME}*g" $file
  sed -i '' "s*STORAGE*${STORAGE}*g" $file
  sed -i '' "s*MEMORY*${MEMORY}*g" $file
  sed -i '' "s*CPU*${CPU}*g" $file
  sed -i '' "s*GPU*${GPU}*g" $file
  sed -i '' "s*CONFIGMAP*${CONFIGMAP}*g" $file
  sed -i '' "s*SECRET*${SECRET}*g" $file
done

cd ${BASE_DIR}
if [[ ! -z $CONFIGMAP ]] || [[ ! -z $SECRET ]]
then
  echo "
generatorOptions:
  disableNameSuffixHash: true
" >> kustomization.yaml
else
  echo "no configmap or secrets provided"
fi

if [[ ! -z $CONFIGMAP ]]
then
  kustomize edit add configmap $CONFIGMAP --from-file=./config/config.toml
  echo "" >> ./patch/deployment_volume_patch.yaml
  cat ./patch/deployment_configmap_patch.yaml >> ./patch/deployment_volume_patch.yaml
else
  echo "No config map setup requested"
fi

if [[ ! -z $SECRET ]]
then
  kustomize edit add secret $SECRET --from-file=./secret/license.sig
  echo "" >> ./patch/deployment_volume_patch.yaml
  cat ./patch/deployment_secret_patch.yaml >> ./patch/deployment_volume_patch.yaml
else
  echo "No license setup requested"
fi

echo "--------------------------"
echo "Completed Patch Generation"
echo " Starting Kustomize Build "
echo "--------------------------"

cd ${WORKING_DIR}
kustomize build ${BASE_DIR} | kubectl apply -f -
