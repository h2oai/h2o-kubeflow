source kustomize_dai.common

DAI_TPLT="${WORKING_DIR}/templates/deployment_patch_template.yaml"
SVC_TPLT="${WORKING_DIR}/templates/service_patch_template.yaml"
VOL_TPLT="${WORKING_DIR}/templates/volume_patch_template.yaml"

echo "GENERATING PATCHES"
cp ${SVC_TPLT} ../driverlessai/overlays/manage/patch/service_patch.yaml.tmpl
cp ${DAI_TPLT} ../driverlessai/overlays/manage/patch/deployment_patch.yaml.tmpl
cp ${VOL_TPLT} ../driverlessai/overlays/manage/patch/volume_patch.yaml.tmpl

sed -i '' "s*NAMESPACE*${NAMESPACE}*g"  ../driverlessai/overlays/manage/patch/service_patch.yaml.tmpl
sed -i '' "s*NAMESPACE*${NAMESPACE}*g" ../driverlessai/overlays/manage/patch/deployment_patch.yaml.tmpl
sed -i '' "s*NAMESPACE*${NAMESPACE}*g" ../driverlessai/overlays/manage/patch/volume_patch.yaml.tmpl

sed -i '' "s*PVC_NAME*${PVC_NAME}*g" ../driverlessai/overlays/manage/patch/deployment_patch.yaml.tmpl

sed -i '' "s*NAME*${NAME}*g" ../driverlessai/overlays/manage/patch/service_patch.yaml.tmpl
sed -i '' "s*NAME*${NAME}*g" ../driverlessai/overlays/manage/patch/deployment_patch.yaml.tmpl
sed -i '' "s*NAME*${NAME}*g" ../driverlessai/overlays/manage/patch/volume_patch.yaml.tmpl

sed -i '' "s*STORAGE*${STORAGE}*g" ../driverlessai/overlays/manage/patch/volume_patch.yaml.tmpl

sed -i '' "s*MEMORY*${MEMORY}*g" ../driverlessai/overlays/manage/patch/deployment_patch.yaml.tmpl
sed -i '' "s*CPU*${CPU}*g" ../driverlessai/overlays/manage/patch/deployment_patch.yaml.tmpl
sed -i '' "s*GPU*${GPU}*g" ../driverlessai/overlays/manage/patch/deployment_patch.yaml.tmpl

mv ../driverlessai/overlays/manage/patch/volume_patch.yaml.tmpl ../driverlessai/overlays/manage/patch/volume_patch.yaml
mv ../driverlessai/overlays/manage/patch/service_patch.yaml.tmpl ../driverlessai/overlays/manage/patch/service_patch.yaml
mv ../driverlessai/overlays/manage/patch/deployment_patch.yaml.tmpl ../driverlessai/overlays/manage/patch/deployment_patch.yaml
echo "PATCHES GENERATE SUCCESSFULLY"

echo "BUILDING and DEPLOYING"
kustomize build ../driverlessai/overlays/manage
