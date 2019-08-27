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

.PHONY: which-cluster
which-cluster:
	echo $(SETKUBECONFIG)

.PHONY: create-testcluster
create-testcluster:
	kind create cluster --name treasuremap

.PHONY: delete-testcluster
delete-testcluster:
	kind delete cluster --name treasuremap

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
	kustomize build site/airsloop -o actual/airsloop
	# cp actual/airsloop/* ./unittests/rendering/airsloop
	diff -r actual/airsloop ./unittests/rendering/airsloop

deploy-airsloop: install
	rm -fr actual/airsloop
	mkdir -p actual/airsloop
	kustomize build site/airsloop -o actual/airsloop
	rm actual/airsloop/pegleg*
	rm actual/airsloop/shipyard*
	rm actual/airsloop/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/airsloop

purge-airsloop: 
	$(SETKUBECONFIG) kubectl delete -f actual/airsloop

rendering-test-airskiff-ubuntu:
	rm -fr actual/airskiff-ubuntu
	mkdir -p actual/airskiff-ubuntu
	kustomize build site/airskiff-ubuntu -o actual/airskiff-ubuntu
	# cp actual/airskiff-ubuntu/* ./unittests/rendering/airskiff-ubuntu
	diff -r actual/airskiff-ubuntu ./unittests/rendering/airskiff-ubuntu

deploy-airskiff-ubuntu: install
	rm -fr actual/airskiff-ubuntu
	mkdir -p actual/airskiff-ubuntu
	kustomize build site/airskiff-ubuntu -o actual/airskiff-ubuntu
	rm actual/airskiff-ubuntu/pegleg*
	rm actual/airskiff-ubuntu/shipyard*
	rm actual/airskiff-ubuntu/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/airskiff-ubuntu

purge-airskiff-ubuntu: 
	$(SETKUBECONFIG) kubectl delete -f actual/airskiff-ubuntu

rendering-test-airskiff-suse:
	rm -fr actual/airskiff-suse
	mkdir -p actual/airskiff-suse
	kustomize build site/airskiff-suse -o actual/airskiff-suse
	# cp actual/airskiff-suse/* ./unittests/rendering/airskiff-suse
	diff -r actual/airskiff-suse ./unittests/rendering/airskiff-suse

deploy-airskiff-suse: install
	rm -fr actual/airskiff-suse
	mkdir -p actual/airskiff-suse
	kustomize build site/airskiff-suse -o actual/airskiff-suse
	rm actual/airskiff-suse/pegleg*
	rm actual/airskiff-suse/shipyard*
	rm actual/airskiff-suse/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/airskiff-suse

purge-airskiff-suse: 
	$(SETKUBECONFIG) kubectl delete -f actual/airskiff-suse


rendering-test-aiab:
	rm -fr actual/aiab
	mkdir -p actual/aiab
	kustomize build site/aiab -o actual/aiab
	# cp actual/aiab/* ./unittests/rendering/aiab
	diff -r actual/aiab ./unittests/rendering/aiab

deploy-aiab: install
	rm -fr actual/aiab
	mkdir -p actual/aiab
	kustomize build site/aiab -o actual/aiab
	rm actual/aiab/pegleg*
	rm actual/aiab/shipyard*
	rm actual/aiab/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/aiab

purge-aiab: 
	$(SETKUBECONFIG) kubectl delete -f actual/aiab

rendering-test-seaworthy:
	rm -fr actual/seaworthy
	mkdir -p actual/seaworthy
	kustomize build site/seaworthy -o actual/seaworthy
	# cp actual/seaworthy/* ./unittests/rendering/seaworthy
	diff -r actual/seaworthy ./unittests/rendering/seaworthy

deploy-seaworthy: install
	rm -fr actual/seaworthy
	mkdir -p actual/seaworthy
	kustomize build site/seaworthy -o actual/seaworthy
	rm actual/seaworthy/pegleg*
	rm actual/seaworthy/shipyard*
	rm actual/seaworthy/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/seaworthy

purge-seaworthy: 
	$(SETKUBECONFIG) kubectl delete -f actual/seaworthy

rendering-test-seaworthy-virt:
	rm -fr actual/seaworthy-virt
	mkdir -p actual/seaworthy-virt
	kustomize build site/seaworthy-virt -o actual/seaworthy-virt
	# cp actual/seaworthy-virt/* ./unittests/rendering/seaworthy-virt
	diff -r actual/seaworthy-virt ./unittests/rendering/seaworthy-virt

deploy-seaworthy-virt: install
	rm -fr actual/seaworthy-virt
	mkdir -p actual/seaworthy-virt
	kustomize build site/seaworthy-virt -o actual/seaworthy-virt
	rm actual/seaworthy-virt/pegleg*
	rm actual/seaworthy-virt/shipyard*
	rm actual/seaworthy-virt/drydock*
	$(SETKUBECONFIG) kubectl apply -f actual/seaworthy-virt

purge-seaworthy-virt: 
	$(SETKUBECONFIG) kubectl delete -f actual/seaworthy-virt

rendering-tests: rendering-test-airsloop rendering-test-airskiff-ubuntu rendering-test-aiab rendering-test-seaworthy rendering-test-seaworthy-virt rendering-test-airskiff-suse

deploy-patch:
	$(SETKUBECONFIG) kubectl patch act openstack-memcached -n openstack --type merge -p $'spec:\n  target_state: deployed'
	# $(SETKUBECONFIG) kubectl patch act nova -n openstack --type merge -p $'spec:\n  target_state: deployed'


.PHONY: kubeval-strict
kubeval-strict:
	kubeval actual/airsloop/ucp_armada.airshipit.org_v1alpha1_armadachart_ucp-shipyard.yaml --openshift --schema-location file:///$(HOME)/src/github.com/keleustes/armada-crd/kubeval --strict

.PHONY: kubeval-remote
kubeval-remote:
	kubeval actual/airsloop/ucp_armada.airshipit.org_v1alpha1_armadachart_ucp-shipyard.yaml --openshift --schema-location https://raw.githubusercontent.com/keleustes/armada-crd/master/kubeval 
