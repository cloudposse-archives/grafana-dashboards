BUILD_HARNESS_VERSION ?= 0.10.2
include $(shell curl --silent -o .build-harness "https://raw.githubusercontent.com/cloudposse/build-harness/$(BUILD_HARNESS_VERSION)/templates/Makefile.build-harness"; echo .build-harness)

export README_DEPS ?= docs/targets.md

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

export NGINX_INGRESS_VERSION ?= 0.19.0

export DJANGO_VERSION ?=

export DS_PROMETHEUS ?= Prometheus

## Name of prometheus datasource for django
export DS_PROM ?= $(DS_PROMETHEUS)

## Import all dashboards
import: kube-prometheus/import nginx/import django/import
	@exit 0

## Import kube-prometheus grafana dashboards from coreos/prometheus-operator
kube-prometheus/import:
	@mkdir -p ./kube-prometheus
	@for dashboard_file in $(KUBE_PROMETHEUS_DASHBOARDS) ; do \
		echo "Fetching kube-prometheus $$dashboard_file version $(KUBE_PROMETHEUS_VERSION)"; \
		curl -s $(KUBE_PROMETHEUS_BASE_URL)/$$dashboard_file | jq .dashboard | \
			envsubst '$${DS_PROMETHEUS}' > ./kube-prometheus/$$dashboard_file ; \
	done

## Import nginx ingress grafana dashboards from kubernetes/ingress-nginx
nginx/import:
	@mkdir -p ./nginx-ingress
	@echo "Fetching nginx ingress dashboard $(NGINX_INGRESS_VERSION)"
	@curl -s https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-$(NGINX_INGRESS_VERSION)/deploy/grafana/dashboards/nginx.yaml | \
		envsubst '$${DS_PROMETHEUS}' > ./nginx-ingress/nginx.json


## Import django grafana dashboards for https://github.com/korfuri/django-prometheus
django/import:
	@mkdir -p ./django
	@echo "Fetching django dashboard ID: 3107 (https://grafana.com/dashboards/3107)"
	@curl -s https://grafana.com/api/dashboards/3107/revisions/2/download | \
		envsubst '$${DS_PROM}' > ./django/django.json
