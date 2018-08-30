export KUBE_PROMETHEUS_VERSION ?= 0.23.2
export KUBE_PROMETHEUS_BASE_URL ?= https://raw.githubusercontent.com/coreos/prometheus-operator/v$(KUBE_PROMETHEUS_VERSION)/helm/grafana/dashboards/

KUBE_PROMETHEUS_DASHBOARDS :=
KUBE_PROMETHEUS_DASHBOARDS += deployment-dashboard.json
KUBE_PROMETHEUS_DASHBOARDS += kubernetes-capacity-planning-dashboard.json
KUBE_PROMETHEUS_DASHBOARDS += kubernetes-cluster-health-dashboard.json
KUBE_PROMETHEUS_DASHBOARDS += kubernetes-cluster-status-dashboard.json
KUBE_PROMETHEUS_DASHBOARDS += kubernetes-control-plane-status-dashboard.json
KUBE_PROMETHEUS_DASHBOARDS += kubernetes-resource-requests-dashboard.json
KUBE_PROMETHEUS_DASHBOARDS += nodes-dashboard.json
KUBE_PROMETHEUS_DASHBOARDS += pods-dashboard.json
KUBE_PROMETHEUS_DASHBOARDS += statefulset-dashboard.json

export DS_PROMETHEUS ?= prometheus

## Write chamber secrets for agent
apply:
	@mkdir -p ./kube-prometheus
	@for dashboard_file in $(KUBE_PROMETHEUS_DASHBOARDS) ; do \
		echo "Fetching kube-prometheus $$dashboard_file version $(KUBE_PROMETHEUS_VERSION)"; \
		curl -s $(KUBE_PROMETHEUS_BASE_URL)/$$dashboard_file | jq .dashboard | envsubst > ./kube-prometheus/$$dashboard_file ; \
	done
