# Copyright 2017 AT&T Intellectual Property.  All other rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: all
all: docs

.PHONY: clean
clean:
	rm -rf doc/build

.PHONY: docs
docs: clean build_docs

.PHONY: build_docs
build_docs:
	tox -e docs

.PHONY: install-tools
install-tools:
	cd /tmp && GO111MODULE=on go get sigs.k8s.io/kind@v0.5.0
	cd /tmp && GO111MODULE=on go get github.com/instrumenta/kubeval@0.13.0

clusterexist=$(shell kind get clusters | grep treasuremap  | wc -l)
ifeq ($(clusterexist), 1)
  testcluster=$(shell kind get kubeconfig-path --name="treasuremap")
  SETKUBECONFIG=KUBECONFIG=$(testcluster)
else
  SETKUBECONFIG=
endif

# KUSTOMIZEBIN=airshipctl kustomize
KUSTOMIZEBIN=kustomize

.PHONY: which-cluster
which-cluster:
	echo $(SETKUBECONFIG)

.PHONY: create-testcluster
create-testcluster:
	kind create cluster --name treasuremap

.PHONY: delete-testcluster
delete-testcluster:
	kind delete cluster --name treasuremap

copy-armadacrd-yaml:
	cp $${HOME}/src/github.com/keleustes/armada-crd/kubectl/armada.airshipit.org_armadacharts.yaml ./deploy/crds/ArmadaChart.yaml
	cp $${HOME}/src/github.com/keleustes/armada-crd/kubectl/armada.airshipit.org_armadachartgroups.yaml ./deploy/crds/ArmadaChartGroup.yaml
	cp $${HOME}/src/github.com/keleustes/armada-crd/kubectl/armada.airshipit.org_armadamanifests.yaml ./deploy/crds/ArmadaManifest.yaml

# Merged from POC
install:
	$(SETKUBECONFIG) kubectl label nodes --all openstack-control-plane=enabled --overwrite
	$(SETKUBECONFIG) kubectl label nodes --all ucp-control-plane=enabled --overwrite
	$(SETKUBECONFIG) kubectl label nodes --all ceph-mds=enabled --overwrite
	$(SETKUBECONFIG) kubectl label nodes --all ceph-mgr=enabled --overwrite
	$(SETKUBECONFIG) kubectl label nodes --all ceph-mon=enabled --overwrite
	$(SETKUBECONFIG) kubectl label nodes --all ceph-rgw=enabled --overwrite
	$(SETKUBECONFIG) kubectl apply -f ./deploy/namespaces
	$(SETKUBECONFIG) kubectl apply -f ./deploy/crds/
	$(SETKUBECONFIG) kubectl apply -f ./deploy/cluster/cluster_role.yaml
	$(SETKUBECONFIG) kubectl apply -f ./deploy/cluster/cluster_role_binding.yaml

install-operators: install
	$(SETKUBECONFIG) kubectl apply -n ceph -f ./deploy/operator
	$(SETKUBECONFIG) kubectl apply -n nfs -f ./deploy/operator
	$(SETKUBECONFIG) kubectl apply -n openstack -f ./deploy/operator
	$(SETKUBECONFIG) kubectl apply -n osh-infra -f ./deploy/operator
	$(SETKUBECONFIG) kubectl apply -n tenant-ceph -f ./deploy/operator
	$(SETKUBECONFIG) kubectl apply -n ucp -f ./deploy/operator

purge-operators:
	$(SETKUBECONFIG) kubectl delete -n ceph -f ./deploy/operator --ignore-not-found=true
	$(SETKUBECONFIG) kubectl delete -n nfs -f ./deploy/operator --ignore-not-found=true
	$(SETKUBECONFIG) kubectl delete -n openstack -f ./deploy/operator --ignore-not-found=true
	$(SETKUBECONFIG) kubectl delete -n osh-infra -f ./deploy/operator --ignore-not-found=true
	$(SETKUBECONFIG) kubectl delete -n tenant-ceph -f ./deploy/operator --ignore-not-found=true
	$(SETKUBECONFIG) kubectl delete -n ucp -f ./deploy/operator --ignore-not-found=true

purge: purge-operators
	$(SETKUBECONFIG) kubectl delete -f ./deploy/cluster/cluster_role_binding.yaml --ignore-not-found=true
	$(SETKUBECONFIG) kubectl delete -f ./deploy/cluster/cluster_role.yaml --ignore-not-found=true
	$(SETKUBECONFIG) kubectl delete -f ./deploy/namespaces --ignore-not-found=true
	$(SETKUBECONFIG) kubectl delete -f ./deploy/crds/ --ignore-not-found=true

rendering-test-airsloop:
	rm -fr actual/airsloop
	mkdir -p actual/airsloop
	$(KUSTOMIZEBIN) build site/airsloop -o actual/airsloop --enable_alpha_plugins
	# cp actual/airsloop/* ./unittests/rendering/airsloop
	diff -r actual/airsloop ./unittests/rendering/airsloop

deploy-airsloop: install
	rm -fr actual/airsloop
	mkdir -p actual/airsloop
	$(KUSTOMIZEBIN) build site/airsloop -o actual/airsloop --enable_alpha_plugins
	rm actual/airsloop/pegleg*
	rm actual/airsloop/shipyard*
	rm actual/airsloop/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/airsloop --validate=true

purge-airsloop:
	$(SETKUBECONFIG) kubectl delete -f actual/airsloop

rendering-test-airskiff-ubuntu:
	rm -fr actual/airskiff-ubuntu
	mkdir -p actual/airskiff-ubuntu
	$(KUSTOMIZEBIN) build site/airskiff-ubuntu -o actual/airskiff-ubuntu --enable_alpha_plugins
	# cp actual/airskiff-ubuntu/* ./unittests/rendering/airskiff-ubuntu
	diff -r actual/airskiff-ubuntu ./unittests/rendering/airskiff-ubuntu

deploy-airskiff-ubuntu: install
	rm -fr actual/airskiff-ubuntu
	mkdir -p actual/airskiff-ubuntu
	$(KUSTOMIZEBIN) build site/airskiff-ubuntu -o actual/airskiff-ubuntu --enable_alpha_plugins
	rm actual/airskiff-ubuntu/pegleg*
	rm actual/airskiff-ubuntu/shipyard*
	rm actual/airskiff-ubuntu/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/airskiff-ubuntu --validate=true

purge-airskiff-ubuntu:
	$(SETKUBECONFIG) kubectl delete -f actual/airskiff-ubuntu

rendering-test-airskiff-suse:
	rm -fr actual/airskiff-suse
	mkdir -p actual/airskiff-suse
	$(KUSTOMIZEBIN) build site/airskiff-suse -o actual/airskiff-suse --enable_alpha_plugins
	# cp actual/airskiff-suse/* ./unittests/rendering/airskiff-suse
	diff -r actual/airskiff-suse ./unittests/rendering/airskiff-suse

deploy-airskiff-suse: install
	rm -fr actual/airskiff-suse
	mkdir -p actual/airskiff-suse
	$(KUSTOMIZEBIN) build site/airskiff-suse -o actual/airskiff-suse --enable_alpha_plugins
	rm actual/airskiff-suse/pegleg*
	rm actual/airskiff-suse/shipyard*
	rm actual/airskiff-suse/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/airskiff-suse --validate=true

purge-airskiff-suse:
	$(SETKUBECONFIG) kubectl delete -f actual/airskiff-suse


rendering-test-aiab:
	rm -fr actual/aiab
	mkdir -p actual/aiab
	$(KUSTOMIZEBIN) build site/aiab -o actual/aiab --enable_alpha_plugins
	# cp actual/aiab/* ./unittests/rendering/aiab
	diff -r actual/aiab ./unittests/rendering/aiab

deploy-aiab: install
	rm -fr actual/aiab
	mkdir -p actual/aiab
	$(KUSTOMIZEBIN) build site/aiab -o actual/aiab --enable_alpha_plugins
	rm actual/aiab/pegleg*
	rm actual/aiab/shipyard*
	rm actual/aiab/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/aiab --validate=true

purge-aiab:
	$(SETKUBECONFIG) kubectl delete -f actual/aiab

rendering-test-aiab-tf:
	rm -fr actual/aiab-tf
	mkdir -p actual/aiab-tf
	$(KUSTOMIZEBIN) build site/aiab-tf -o actual/aiab-tf --enable_alpha_plugins
	# cp actual/aiab-tf/* ./unittests/rendering/aiab-tf
	diff -r actual/aiab-tf ./unittests/rendering/aiab-tf

deploy-aiab-tf: install
	rm -fr actual/aiab-tf
	mkdir -p actual/aiab-tf
	$(KUSTOMIZEBIN) build site/aiab-tf -o actual/aiab-tf --enable_alpha_plugins
	rm actual/aiab-tf/pegleg*
	rm actual/aiab-tf/shipyard*
	rm actual/aiab-tf/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/aiab-tf --validate=true

purge-aiab-tf:
	$(SETKUBECONFIG) kubectl delete -f actual/aiab-tf

rendering-test-seaworthy:
	rm -fr actual/seaworthy
	mkdir -p actual/seaworthy
	$(KUSTOMIZEBIN) build site/seaworthy -o actual/seaworthy --enable_alpha_plugins
	# cp actual/seaworthy/* ./unittests/rendering/seaworthy
	diff -r actual/seaworthy ./unittests/rendering/seaworthy

deploy-seaworthy: install
	rm -fr actual/seaworthy
	mkdir -p actual/seaworthy
	$(KUSTOMIZEBIN) build site/seaworthy -o actual/seaworthy --enable_alpha_plugins
	rm actual/seaworthy/pegleg*
	rm actual/seaworthy/shipyard*
	rm actual/seaworthy/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/seaworthy --validate=true

purge-seaworthy:
	$(SETKUBECONFIG) kubectl delete -f actual/seaworthy

rendering-test-seaworthy-virt:
	rm -fr actual/seaworthy-virt
	mkdir -p actual/seaworthy-virt
	$(KUSTOMIZEBIN) build site/seaworthy-virt -o actual/seaworthy-virt --enable_alpha_plugins
	# cp actual/seaworthy-virt/* ./unittests/rendering/seaworthy-virt
	diff -r actual/seaworthy-virt ./unittests/rendering/seaworthy-virt

deploy-seaworthy-virt: install
	rm -fr actual/seaworthy-virt
	mkdir -p actual/seaworthy-virt
	$(KUSTOMIZEBIN) build site/seaworthy-virt -o actual/seaworthy-virt --enable_alpha_plugins
	rm actual/seaworthy-virt/pegleg*
	rm actual/seaworthy-virt/shipyard*
	rm actual/seaworthy-virt/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/seaworthy-virt --validate=true

purge-seaworthy-virt:
	$(SETKUBECONFIG) kubectl delete -f actual/seaworthy-virt

rendering-tests: rendering-test-airsloop rendering-test-airskiff-ubuntu rendering-test-aiab rendering-test-seaworthy rendering-test-seaworthy-virt rendering-test-airskiff-suse rendering-test-aiab-tf

deploy-purge-tests: deploy-aiab purge-aiab deploy-airsloop purge-airsloop deploy-aiab-tf purge-aiab-tf deploy-airskiff-suse purge-airskiff-suse deploy-airskiff-ubuntu purge-airskiff-ubuntu

deploy-patch:
	$(SETKUBECONFIG) kubectl patch act openstack-memcached -n openstack --type merge -p $'spec:\n  target_state: deployed'
	# $(SETKUBECONFIG) kubectl patch act nova -n openstack --type merge -p $'spec:\n  target_state: deployed'

.PHONY: kubeval-remote
kubeval-remote:
	kubeval actual/airsloop/ucp_armada.airshipit.org_v1alpha1_armadachart_ucp-shipyard.yaml --schema-location https://raw.githubusercontent.com/keleustes/armada-crd/master/kubeval

.PHONY: kubeval-airsloop
kubeval-airsloop: rendering-test-airsloop
	@for f in $(shell ls ./actual/airsloop/*armadachart*); do \
		kubeval $${f} --schema-location file://$${HOME}/src/github.com/keleustes/armada-crd/kubeval --strict; \
	done || true

.PHONY: kubeval-airskiff-ubuntu
kubeval-airskiff-ubuntu: rendering-test-airskiff-ubuntu
	@for f in $(shell ls ./actual/airskiff-ubuntu/*armadachart*); do \
		kubeval $${f} --schema-location file://$${HOME}/src/github.com/keleustes/armada-crd/kubeval --strict; \
	done || true

.PHONY: kubeval-airskiff-suse
kubeval-airskiff-suse: rendering-test-airskiff-suse
	@for f in $(shell ls ./actual/airskiff-suse/*armadachart*); do \
		kubeval $${f} --schema-location file://$${HOME}/src/github.com/keleustes/armada-crd/kubeval --strict; \
	done || true

.PHONY: kubeval-aiab
kubeval-aiab: rendering-test-aiab
	@for f in $(shell ls ./actual/aiab/*armadachart*); do \
		kubeval $${f} --schema-location file://$${HOME}/src/github.com/keleustes/armada-crd/kubeval --strict; \
	done || true

.PHONY: kubeval-aiab-tf
kubeval-aiab-tf: rendering-test-aiab-tf
	@for f in $(shell ls ./actual/aiab-tf/*armadachart*); do \
		kubeval $${f} --schema-location file://$${HOME}/src/github.com/keleustes/armada-crd/kubeval --strict; \
	done || true

.PHONY: kubeval-seaworthy
kubeval-seaworthy: rendering-test-seaworthy
	@for f in $(shell ls ./actual/seaworthy/*armadachart*); do \
		kubeval $${f} --schema-location file://$${HOME}/src/github.com/keleustes/armada-crd/kubeval --strict; \
	done || true

.PHONY: kubeval-seaworthy-virt
kubeval-seaworthy-virt: rendering-test-seaworthy-virt
	@for f in $(shell ls ./actual/seaworthy-virt/*armadachart*); do \
		kubeval $${f} --schema-location file://$${HOME}/src/github.com/keleustes/armada-crd/kubeval --strict; \
	done || true

.PHONY: kubeval-checks
kubeval-checks: kubeval-airsloop kubeval-airskiff-ubuntu kubeval-aiab kubeval-seaworthy kubeval-seaworthy-virt kubeval-airskiff-suse kubeval-aiab-tf

