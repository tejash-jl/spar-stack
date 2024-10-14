kubectl delete ns spar
kubectl delete ns istio-system
helm uninstall cert-manager -n cert-manager
helm uninstall spar -n spar
