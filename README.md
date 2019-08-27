# Treasuremap

This documentation project outlines a reference architecture for automated
cloud provisioning and management, leveraging a collection of interoperable
open-source tools.


## Architecture
To get started, see [architecture](https://airship-treasuremap.readthedocs.io/en/latest/index.html).

## Deckhand-Kustomize POC

- This directory aims at finding a way to migrate from the Airship 1.x structure
  to the possible Airship 2.x structure.

###  Convertion Procedure

- On August 26th, a (temporary) fork of [treasuremap](https://opendev.org/airship/treasuremap) has been created.
  the master branch of this fork is supposed to be aligned with upstream and official treasuremap repo.
- The kustomize branch of the repo has been created to enable a tracking of the changes necessary to adapt
  to kustomize.
- The intermediates branches are: `convert2kustomize`, `reformat`, `rendering`
- Some of the tools used to during this convertion have been saved [here](https://github.com/keleustes/treasuremap/tree/kustomize/tools/convert2kustomize).

###  Building Kustomize

```bash
prompt$ git clone -b allinone https://github.com/keleustes/kustomize.git
Cloning into 'kustomize'...
remote: Enumerating objects: 66, done.
remote: Counting objects: 100% (66/66), done.
remote: Compressing objects: 100% (45/45), done.
remote: Total 22735 (delta 33), reused 41 (delta 20), pack-reused 22669
Receiving objects: 100% (22735/22735), 24.58 MiB | 1.82 MiB/s, done.
Resolving deltas: 100% (11314/11314), done.
Checking connectivity... done.

prompt$ cd kustomize/
prompt$ GO111MODULE=on go build -o $HOMEbin/kustomize cmd/kustomize/main.go
```

###  Testing Rendering

###  Site Airsloop deployment

```bash
mkdir -p actual/airsloop
rm -f actual/airsloop/*
kustomize build site/airsloop -o actual/airsloop
```

or if kubectl is pointing at an active kubernetes cluster


```bash
make create-testcluster
make deploy-airsloop
make purge-airsloop
```

###  Site Airskiff-Ubuntu deployment

```bash
mkdir -p actual/airskiff-ubuntu
rm -f actual/airskiff-ubuntu/*
kustomize build site/airskiff-ubuntu -o actual/airskiff-ubuntu
```

or if kubectl is pointing at an active kubernetes cluster

```bash
make create-testcluster
make deploy-airskiff-ubuntu
make purge-airskiff-ubuntu
```

###  Site Airskiff-Suse deployment

```bash
mkdir -p actual/airskiff-suse
rm -f actual/airskiff-suse/*
kustomize build site/airskiff-suse -o actual/airskiff-suse
```

or if kubectl is pointing at an active kubernetes cluster

```bash
make create-testcluster
make deploy-airskiff-suse
make purge-airskiff-suse
```

###  Site Airship-Seaworthy deployment

```bash
mkdir -p actual/airship-seaworthy
rm -f actual/airship-seaworthy/*
kustomize build site/airship-seaworthy -o actual/airship-seaworthy
```

or if kubectl is pointing at an active kubernetes cluster

```bash
make create-testcluster
make deploy-seaworthy
make purge-seaworthy
```

###  Site Airship-Seaworthy-Virt deployment

```bash
mkdir -p actual/airship-seaworthy-virt
rm -f actual/airship-seaworthy-virt/*
kustomize build site/airship-seaworthy-virt -o actual/airship-seaworthy-virt
```

or if kubectl is pointing at an active kubernetes cluster

```bash
make create-testcluster
make deploy-seaworthy-virt
make purge-seaworthy-virt
```

###  Site Airship-In-A-Bottle deployment

```bash
mkdir -p actual/aiab
rm -f actual/aiab/*
kustomize build site/aiab -o actual/aiab
```

or if kubectl is pointing at an active kubernetes cluster

```bash
make create-testcluster
make deploy-aiab
make purge-aiab
```

###  Site Airship Tugsten Fabric deployment

```bash
mkdir -p actual/aiab-tf
rm -f actual/aiab-tf/*
kustomize build site/aiab-tf -o actual/aiab-tf
```

or if kubectl is pointing at an active kubernetes cluster

```bash
make create-testcluster
make deploy-aiab-tf
make purge-aiab-tf
```

### Deployment tests

To install armada-operator (one per namespace):

```bash
make create-testcluster
make install-operators
```

To access the logs:

```bash
kubectl get pods --all-namespaces | grep operator | awk '{print "kubectl logs -n "$1" "$2"> "$1".log"}'  > doIt
chmod u+x doIt
./doIt
```

To purge armada-operator (one per namespace):

```bash
make purge-operators
```
