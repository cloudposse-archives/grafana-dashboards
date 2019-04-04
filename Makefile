BUILD_HARNESS_VERSION ?= 0.10.2
include $(shell curl --silent -o .build-harness "https://raw.githubusercontent.com/cloudposse/build-harness/$(BUILD_HARNESS_VERSION)/templates/Makefile.build-harness"; echo .build-harness)

export README_DEPS ?= docs/targets.md

export KUBE_PROMETHEUS_VERSION ?= 0.29.0
export KUBE_PROMETHEUS_DEFINITION_FILE ?= https://raw.githubusercontent.com/coreos/prometheus-operator/v$(KUBE_PROMETHEUS_VERSION)/contrib/kube-prometheus/manifests/grafana-dashboardDefinitions.yaml

KUBE_PROMETHEUS_DEFINITION_FILE_LOCAL ?= /tmp/grafana-dashboardDefinitions.yaml

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
	@rm -rf ./kube-prometheus
	@mkdir -p ./kube-prometheus
	@echo "Fetching kube-prometheus definitions file version $(KUBE_PROMETHEUS_VERSION)";
	@curl -s -o $(KUBE_PROMETHEUS_DEFINITION_FILE_LOCAL) $(KUBE_PROMETHEUS_DEFINITION_FILE)
	@yq r $(KUBE_PROMETHEUS_DEFINITION_FILE_LOCAL) -j | jq -cr '.items[].data | keys[]' | xargs -I {} make kube-prometeus/import-file FILE={}

## Create dashboard file from one of sections in KUBE_PROMETHEUS_DEFINITION_FILE (used by kube-prometheus/import target)
kube-prometeus/import-file:
	@yq r $(KUBE_PROMETHEUS_DEFINITION_FILE_LOCAL) -j | jq -cr '.items[] | select(.data | has("$(FILE)")) | .data["$(FILE)"]' > ./kube-prometheus/$(FILE)

## Import nginx ingress grafana dashboards from kubernetes/ingress-nginx
nginx/import:
	@mkdir -p ./nginx-ingress
	@echo "Fetching nginx ingress dashboard $(NGINX_INGRESS_VERSION)"
	@curl -s https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-$(NGINX_INGRESS_VERSION)/deploy/grafana/dashboards/nginx.yaml | \
		envsubst '$${DS_PROMETHEUS}' > ./nginx-ingress/nginx.json


## Import django grafana dashboards for https://github.com/korfuri/django-prometheus
django/import:
	@mkdir -p ./django
	@echo "Fetching django dashboard ID: 7996 (https://grafana.com/dashboards/7996)"
	@curl -s https://grafana.com/api/dashboards/7996/revisions/2/download | \
		envsubst '$${DS_PROMETHEUS}' > ./django/django.json
