#!/bin/bash
set -e

echo "=========================================="
echo "Platform Module Deployment Started"
echo "=========================================="

# Environment variables
ENVIRONMENT="${ENVIRONMENT:-sit}"
AWS_REGION="${AWS_DEFAULT_REGION:-ap-southeast-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME}"

echo "Environment: ${ENVIRONMENT}"
echo "AWS Region: ${AWS_REGION}"
echo "EKS Cluster: ${CLUSTER_NAME}"

# Check if kubectl is configured
echo "Checking Kubernetes connectivity..."
kubectl cluster-info
kubectl get nodes

# Deploy platform components
echo "Deploying platform modules..."

# Example: Deploy ingress controller (if needed)
if [ "${NGINX_INGRESS_ENABLE:-false}" = "true" ]; then
    echo "Deploying NGINX Ingress Controller..."
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace ingress-nginx \
        --create-namespace \
        --set controller.service.type=LoadBalancer \
        --wait --timeout 5m
    
    echo "NGINX Ingress Controller deployed successfully"
fi

# Example: Deploy metrics-server (if needed)
if [ "${METRICS_SERVER_ENABLE:-false}" = "true" ]; then
    echo "Deploying Metrics Server..."
    helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
    helm repo update
    
    helm upgrade --install metrics-server metrics-server/metrics-server \
        --namespace kube-system \
        --set args={--kubelet-insecure-tls} \
        --wait --timeout 5m
    
    echo "Metrics Server deployed successfully"
fi

echo "=========================================="
echo "Platform Module Deployment Completed"
echo "=========================================="
