#!/usr/bin/env bash
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <service account name>"
  exit 1
fi

SERVICE_ACCOUNT_NAME=$1
NEW_CONTEXT="${CONFIG_CONTEXT}:tester"

KUBECONFIG_FILE="kubeconfig_${SERVICE_ACCOUNT_NAME}.yaml"
CONTEXT=$(kubectl config current-context)

NAMESPACE=$(kubectl get sa/tester1 -o jsonpath='{.metadata.namespace}')

SECRET_NAME=$(kubectl get serviceaccount "${SERVICE_ACCOUNT_NAME}" \
  --context "${CONTEXT}" \
  --namespace "${NAMESPACE}" \
  -o jsonpath='{.secrets[0].name}')
TOKEN_DATA=$(kubectl get secret "${SECRET_NAME}" \
  --context "${CONTEXT}" \
  --namespace "${NAMESPACE}" \
  -o jsonpath='{.data.token}')

TOKEN=$(echo "${TOKEN_DATA}" | base64 -d)

# Create dedicated kubeconfig
# Create a full copy
kubectl config view --raw > "${KUBECONFIG_FILE}.full.tmp"
# Switch working context to correct context
kubectl --kubeconfig "${KUBECONFIG_FILE}.full.tmp" config use-context "${CONTEXT}"
# Minify
kubectl --kubeconfig "${KUBECONFIG_FILE}.full.tmp" \
  config view --flatten --minify > "${KUBECONFIG_FILE}.tmp"
# Rename context
kubectl config --kubeconfig "${KUBECONFIG_FILE}.tmp" \
  rename-context "${CONTEXT}" "${NEW_CONTEXT}"
# Create token user
kubectl config --kubeconfig "${KUBECONFIG_FILE}.tmp" \
  set-credentials "${CONTEXT}-${NAMESPACE}-token-user" \
  --token "${TOKEN}"
# Set context to use token user
kubectl config --kubeconfig "${KUBECONFIG_FILE}.tmp" \
  set-context "${NEW_CONTEXT}" --user "${CONTEXT}-${NAMESPACE}-token-user"
# Set context to correct namespace
kubectl config --kubeconfig "${KUBECONFIG_FILE}.tmp" \
  set-context "${NEW_CONTEXT}" --namespace "${NAMESPACE}"
# Flatten/minify kubeconfig
kubectl config --kubeconfig "${KUBECONFIG_FILE}.tmp" \
  view --flatten --minify > "${KUBECONFIG_FILE}"
# Remove tmp
rm "${KUBECONFIG_FILE}.full.tmp"
rm "${KUBECONFIG_FILE}.tmp"
