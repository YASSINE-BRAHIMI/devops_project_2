# Rapport de Projet Final - DevOps

**Projet Final :** Master DSBD & IA
**Thème :** Mise en place d'une infrastructure DevOps avec CI/CD, Kubernetes, et Monitoring

---

## 1. Introduction et Objectifs
Ce rapport détaille la conception, le déploiement et l'automatisation d'une infrastructure DevOps complète hébergée sur le cloud AWS. L'objectif principal de ce projet est de simuler un environnement de production en conteneurisant une application, en automatisant son déploiement via une chaîne CI/CD, et en orchestrant les services avec Kubernetes.

Les objectifs atteints sont :
- Création d'une API REST Python/Flask et sa conteneurisation (Docker).
- Automatisation de l'infrastructure cloud avec **Terraform** (Création du VPC, Subnets, et instances EC2).
- Configuration des serveurs avec **Ansible**.
- Orchestration du déploiement avec **Kubernetes** (Distribution légère K3s).
- Automatisation des tests et déploiements avec **GitHub Actions**.

## 2. Architecture du Projet

L'architecture est structurée de manière hautement disponible et automatisée.

1. **Infrastructure (AWS)** : Un réseau VPC contenant un sous-réseau public ouvert sur internet via une Internet Gateway. Deux instances EC2 de type `t3.micro` y sont déployées (un Master Node et un Worker Node).
2. **Orchestration (K3s)** : Le cluster Kubernetes relie le Master et le Worker, permettant la répartition de la charge.
3. **Pipeline (GitHub Actions)** : À chaque `push` sur la branche `main`, GitHub Actions compile l'image Docker, la publie sur Docker Hub, et applique les modifications directement sur le cluster Kubernetes distant.
4. **Monitoring** : Prometheus et Grafana sont configurés pour surveiller l'état des noeuds et de l'application.

> *Note: Une architecture sous Draw.io a été conceptualisée, modélisant les liens entre GitHub, Docker Hub, AWS EC2, et l'utilisateur final.*

## 3. Code source et Conteneurisation (Dossier `/app`)

L'application est une API développée en Flask.
- **app.py** : Expose les routes `/` et `/health` pour vérifier l'état du service.
- **Dockerfile** : Utilise une image légère `python:3.9-slim`, installe les dépendances via `requirements.txt` et expose le port 5000.

## 4. Automatisation avec Terraform et Ansible (Dossiers `/terraform` & `/ansible`)

### Terraform
Les scripts Terraform (`main.tf`, `variables.tf`, `terraform.tfvars`) déclarent l'Infrastructure as Code (IaC). 
- Ils créent le pare-feu (Security Group) autorisant les ports nécessaires (22, 6443, 80, 30000-32767).
- Ils déploient les machines et installent K3s via le script d'initialisation `user_data` pour un gain de temps.

### Ansible
L'inventaire Ansible (`inventory.ini`) répertorie les adresses IP publiques des instances. Les playbooks (`install_k3s.yml`, `setup_docker.yml`) valident la bonne configuration des noeuds en mode Idempotent.

## 5. Pipeline CI/CD (Dossier `/.github`)

L'outil **GitHub Actions** a été privilégié pour son intégration native au dépôt de code.
Le fichier `.github/workflows/deploy.yml` effectue les tâches suivantes :
1. Récupération du code source.
2. Connexion à Docker Hub via les secrets (DOCKERHUB_USERNAME, DOCKER_PASSWORD).
3. Build et Push de l'image Docker vers le registre.
4. Connexion au cluster Kubernetes via le secret `KUBECONFIG`.
5. Injection dynamique de l'image fraîchement créée et application du déploiement via `kubectl apply`.

## 6. Manifests Kubernetes et Monitoring (Dossiers `/k8s` & `/monitoring`)

L'application est gérée de la manière suivante :
- **Deployment (`k8s/deployment.yaml`)** : Gère 2 réplicas (pods) de l'API Flask pour assurer la tolérance aux pannes.
- **Service** : De type `NodePort`, il expose l'API sur le port 80 publiquement pour y accéder via l'IP de l'instance AWS.
- **Monitoring** : Les fichiers `prometheus.yaml` et `grafana.yaml` permettent de déployer la stack de supervision (optionnel mais fonctionnel).

## 7. Documentation pour reproduire l'infrastructure

Pour déployer complètement ce projet à partir de zéro, suivez ces étapes :

1. **Générer une clé SSH locale :**
   ```bash
   ssh-keygen -t rsa -b 2048 -f ~/.ssh/devops_key_v2
   ```
2. **Déployer l'infrastructure AWS :**
   Mettre la clé publique générée dans `terraform/terraform.tfvars`, puis :
   ```bash
   cd terraform
   terraform init
   terraform apply -auto-approve
   ```
3. **Récupérer le Kubeconfig :**
   Une fois les instances prêtes (10 minutes), connectez-vous au noeud Master via SSH, copiez le contenu de `/etc/rancher/k3s/k3s.yaml` et remplacez l'IP en local par l'IP publique du Master.
4. **Configurer GitHub et Lancer CI/CD :**
   Ajoutez `DOCKERHUB_USERNAME`, `DOCKER_PASSWORD`, et `KUBECONFIG` dans les secrets GitHub. Faites un `git push` pour observer la magie s'opérer.

---
**Conclusion :** 
Ce projet couvre la totalité du cycle de vie d'une application moderne, de la ligne de code (Dev) jusqu'au déploiement et la surveillance en production (Ops), tout en utilisant des outils open-source standards de l'industrie.
