<div align="center">

![Cloud-as-Code logo](logo.png "Cloud-as-Code logo")

<img src="" alt="Node Uptime">
<img src="" alt="Cluster Uptime">
<img src="" alt="Service Uptime">

<h3>Bootstrap and GitOps sources to get my cloud infrastructure set up consistently.</h3>

</div>

# ☁️ Cloud-as-Code (CaC™)

This repository was born out of the need to better monitor the health and uptime of an ever-growing environment of services.
It contains everything required to bootstrap and manage my cloud infrastructure.
It is based on the [GitOps](https://www.gitops.tech/) methodology and uses [Argo CD](https://argo-cd.readthedocs.io/en/stable/) as the GitOps delivery mechanism.

## 🔰 Overview

At the highest possible level, this repo and CaC workflow consists of two parts:
- [terraform](terraform) contains the stage 1 bootstrapping for the cluster nodes.
  This includes the partial infrastructure bootstrapping on OCI, installation of a base OS and setup of a kubernetes distribution.
  After completion of this stage, the cluster is ready and capable of running workloads.
- [argo](argo) contains the final stage 2 GitOps cluster configuration.
  This includes everything running _inside_ kubernetes in the cluster and ranges from basic system infrastructure like [ingress](https://kubernetes.github.io/ingress-nginx/), [CCM](https://github.com/oracle/oci-cloud-controller-manager/tree/master/manifests/cloud-controller-manager) and [CSI](https://github.com/oracle/oci-cloud-controller-manager/tree/master/manifests/container-storage-interface) to more user-style applications such as [uptime monitoring](https://gatus.io/) apps.
  The argo installation on the cluster is not yet performed automatically, but could also be triggered from stage 1 easily.
  The contained argo applications are automatically installed and/or reconciled on the cluster without* user interaction.
  After completion of this stage, the cluster is fully set up and performs its monitoring and alerting duties.

## 📐 Tech Stack

| Component                                        | Purpose                                | Notes                                                                                                               |
| ------------------------------------------------ | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| [terraform](https://www.terraform.io/)           | Infrastructure Bootstrap               |                                                                                                                     |
| [Ubuntu Server 24.04](https://ubuntu.com/server) | Base Operating System                  |                                                                                                                     |
| [k3s](https://k3s.io/)                           | k8s _Distribution_ / Install Mechanism | stacked HA controlplanes                                                                                            |
| [ArgoCD](https://argo-cd.readthedocs.io/)        | GitOps Automation inside the Cluster   |                                                                                                                     |
| [SOPS](https://getsops.io/)                      | Secrets Management                     | via [ksops](https://github.com/viaduct-ai/kustomize-sops), using [age](https://age-encryption.org/) rather than pgp |

## 📱 Applications

### 🤖 System-Level

<table>
    <tr>
        <th></th>
        <th>Name</th>
        <th>Purpose</th>
        <th>Notes</th>
    </tr>
    <tr>
        <td><img width="32" src="https://docs.oracle.com/favicon.ico"></td>
        <td><a href="https://github.com/oracle/oci-cloud-controller-manager">OCI CCM / CSI</a></td>
        <td>Oracle Cloud Infrastucture k8s Automation</td>
        <td></td>
    </tr>
    <tr>
        <td><img width="32" src="https://raw.githubusercontent.com/rancher/ui/refs/heads/master/public/assets/images/logos/main.svg"></td>
        <td><a href="https://github.com/oracle/oci-cloud-controller-manager">system-upgrade-controller</a></td>
        <td>System Upgrade Controller</td>
        <td></td>
    </tr>
    <tr>
        <td><img width="32" src="https://raw.githubusercontent.com/kubernetes-sigs/external-dns/refs/heads/master/docs/img/external-dns.png"></td>
        <td><a href="https://kubernetes-sigs.github.io/external-dns/">external-dns</a></td>
        <td>DNS Management Automation</td>
        <td></td>
    </tr>
    <tr>
        <td><img width="32" src="https://raw.githubusercontent.com/cert-manager/cert-manager/refs/heads/master/logo/logo.svg"></td>
        <td><a href="https://cert-manager.io/">cert-manager</a></td>
        <td>Automated Certificate Management</td>
        <td>Let's Encrypt via ACME DNS</td>
    </tr>
    <tr>
        <td><img width="32" src="https://raw.githubusercontent.com/nginx/nginx.org/refs/heads/main/img/ingress_logo.svg"></td>
        <td><a href="https://kubernetes.github.io/ingress-nginx/">ingress-nginx</a></td>
        <td>Ingress Controller</td>
        <td></td>
    </tr>
    <tr>
        <td><img width="32" src="https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg.github.io/refs/heads/main/assets/images/hero_image.svg"></td>
        <td><a href="https://cloudnative-pg.io/">CloudNativePG</a></td>
        <td>Cloud-Native PostgreSQL Operator</td>
        <td></td>
    </tr>
    <tr>
        <td><img width="32" src="https://raw.githubusercontent.com/stakater/Reloader/refs/heads/master/theme_override/resources/assets/images/favicon.svg"></td>
        <td><a href="https://docs.stakater.com/reloader/">reloader</a></td>
        <td>Hot-Reload for ALL Workloads</td>
        <td></td>
    </tr>
</table>

### 👨‍💻 User-Level

<table>
    <tr>
        <th></th>
        <th>Name</th>
        <th>Purpose</th>
        <th>Notes</th>
    </tr>
    <tr>
        <td><img width="32" src="https://gatus.io/img/logo.svg"></td>
        <td><a href="https://gatus.io/">Gatus</a></td>
        <td>Endpoint Monitor and Status Page</td>
        <td>Monitor configuration as code</td>
    </tr>
</table>