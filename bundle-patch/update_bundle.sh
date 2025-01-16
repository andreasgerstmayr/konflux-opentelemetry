#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export OTEL_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-collector@sha256:b04830a0bec454858d1a91b629e226e0480f6c2991d1ba564bc04a70f2e5ed87"
# Separate due to merge conflicts
export OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-target-allocator@sha256:5fb1252c8619502f345a3cd04eb7c38f610b7bf74dbcd6f271803b2b8a0fcedf"
# Separate due to merge conflicts
export OTEL_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-operator@sha256:826892943ba3494eb3c853ef61ed36699fcb572c697d5007ea47a93801df6ab4"
# Separate due to merge conflicts
# TODO, we used to set the proxy image per OCP version
export OSE_KUBE_RBAC_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-kube-rbac-proxy@sha256:7efeeb8b29872a6f0271f651d7ae02c91daea16d853c50e374c310f044d8c76c"

if [[ $REGISTRY == "registry.redhat.io" ||  $REGISTRY == "registry.stage.redhat.io" ]]; then
  OTEL_COLLECTOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/opentelemetry-collector-rhel8@${OTEL_COLLECTOR_IMAGE_PULLSPEC:(-71)}"
  OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/opentelemetry-target-allocator-rhel8@${OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC:(-71)}"
  OTEL_OPERATOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/opentelemetry-rhel8-operator@${OTEL_OPERATOR_IMAGE_PULLSPEC:(-71)}"
fi

export CSV_FILE=/manifests/opentelemetry-operator.clusterserviceversion.yaml

sed -i "s#opentelemetry-collector-container-pullspec#$OTEL_COLLECTOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#opentelemetry-target-allocator-container-pullspec#$OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#ose-kube-rbac-proxy-container-pullspec#$OSE_KUBE_RBAC_PROXY_PULLSPEC#g" patch_csv.yaml
sed -i "s#opentelemetry-operator-container-pullspec#$OTEL_OPERATOR_IMAGE_PULLSPEC#g" patch_csv.yaml

#export AMD64_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
#export ARM64_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
#export PPC64LE_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
#export S390X_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')
export AMD64_BUILT=true
export ARM64_BUILT=true
export PPC64LE_BUILT=true
export S390X_BUILT=true

export EPOC_TIMESTAMP=$(date +%s)

# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py
