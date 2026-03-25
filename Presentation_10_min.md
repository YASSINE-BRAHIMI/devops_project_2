# Plan de Présentation (10 Minutes)
**Projet : Master DSBD & IA - Infrastructure DevOps**

---

## Slide 1 : Titre (1 min)
- **Titre** : Mise en place d'une infrastructure DevOps Complète
- **Présentateur** : *Votre Nom*
- **Introduction** : Accroche sur l'importance du DevOps pour accélérer le "Time to Market" et fiabiliser les déploiements.
- **Objectif** : Présenter la chaîne complète de la création de l'infrastructure jusqu'au déploiement du code (CI/CD).

## Slide 2 : L'Application et Docker (1.5 min)
- **Qu'est-ce que l'application ?** Une API REST légère en Python/Flask.
- **Pourquoi Docker ?** Isoler l'environnement d'exécution.
- Expliquer brièvement le `Dockerfile` (image de base `python:3.9-slim`, copie du code, installation des `requirements.txt`).

## Slide 3 : Infrastructure as Code (IaC) avec Terraform (2 min)
- **Le concept** : L'infrastructure décrite sous forme de code.
- **Ce qui a été déployé sur AWS** :
  - Création du réseau (`VPC`, `Subnets`, `Internet Gateway`).
  - Déploiement de 2 machines `t3.micro` (Master et Worker).
  - Gestion des pare-feux (`Security Groups` pour SSH, K3s, HTTP).
- **Le script d'initialisation (`user_data`)** : Installation automatique de Docker et Kubernetes au démarrage, pour gagner un temps précieux.

## Slide 4 : Configuration & Ansible (1 min)
- **Rôle d'Ansible** : Gérer la configuration (Configuration Management).
- **L'Inventaire** : Automatisation de la liste des serveurs.
- **Les Playbooks** : Mentionner les scripts préparés (`install_k3s.yml`, `setup_docker.yml`) démontrant l'automatisation sans intervention humaine.

## Slide 5 : L'Orchestration avec Kubernetes / K3s (1.5 min)
- **Le choix de K3s** : Une version allégée et optimisée de Kubernetes idéale pour des instances `t3.micro`.
- **L'Architecture K8s locale** : 
  - Un master pour contrôler le cluster.
  - Un worker pour exécuter les conteneurs.
- **Les Manifests** : Explication rapide de `deployment.yaml` (2 réplicas) et du `Service NodePort` exposant le port 80.

## Slide 6 : Le coeur du projet - La CI/CD avec GitHub Actions (2 min)
- **Le Pipeline** : `.github/workflows/deploy.yml`
- **L'intégration Continue (CI)** :
  - Déclenchée à chaque `git push`.
  - Compile l'image Docker avec la nouvelle version de l'application.
  - Publie automatiquement sur Docker Hub en utilisant des identifiants sécurisés (`Secrets`).
- **Le Déploiement Continu (CD)** :
  - Le pipeline se connecte au serveur AWS en utilisant le fichier `KUBECONFIG`.
  - Applique les changements sur K3s avec `kubectl`.

## Slide 7 : Monitoring & Conclusion (1 min)
- **Aperçu du Monitoring** : Intégration de Prometheus et Grafana pour superviser les ressources (`monitoring/`).
- **Conclusion globale** :
  - Succès de la mise en place d'une chaîne de bout en bout "Zero Touch".
  - Les principes DevOps (IaC, CI/CD, Conteneurisation) sont appliqués.
  - Outils utilisés, 100% open-source et gratuits (AWS Free Tier).

---

> **Conseil pour l'orateur** : 
> Ne lisez pas vos slides ! Expliquez quels outils vous avez choisis et *pourquoi* vous les avez choisis. Gardez un ton confiant et montrez que tous les morceaux du puzzle s'assemblent grâce à l'automatisation.
