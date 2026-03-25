## Master DSBD & IA: Infrastructure DevOps Project

Ce projet met en place une infrastructure complète avec CI/CD, Kubernetes (K3s), et Monitoring sur AWS.

## Architecture du Projet
1. **Terraform**: Provisionnement de 2 instances EC2 (Master & Worker) dans un VPC dédié.
2. **Ansible**: Installation automatique de Docker et K3s.
3. **Application**: API REST Flask conteneurisée.
4. **Kubernetes**: Déploiement de l'application avec auto-scaling et load balancing (NodePort).
5. **CI/CD**: Pipeline GitHub Actions pour le build, le push Docker Hub et le déploiement.

## Structure des Dossiers
- `/terraform`: Fichiers de configuration de l'infrastructure AWS.
- `/ansible`: Playbooks pour la configuration des noeuds.
- `/app`: Code source de l'application Flask et Dockerfile.
- `/k8s`: Manifestes Kubernetes pour le déploiement.
- `/monitoring`: Configuration de Prometheus et Grafana.
- `/.github/workflows`: Pipeline CI/CD.

## Guide de Déploiement "A à Z" (Simplifié)

### 1. Pré-requis
- AWS CLI configuré.
- Terraform installé.

### 2. Étape Unique : Déploiement Automatique
Tout est maintenant 100% automatisé ! Je viens de générer votre clé SSH et de l'intégrer dans la configuration.

```powershell
# Déployer (Terraform installe tout : Docker + K3s)
cd terraform
terraform init
terraform apply
```
*(Tapez `yes` quand demandé).*

### 3. Configuration de la CI/CD (GitHub Secrets)
Pour que GitHub Actions puisse se connecter à votre cluster Kubernetes et publier l'image Docker, vous devez configurer 3 secrets dans votre dépôt GitHub (`Settings` > `Secrets and variables` > `Actions` > `New repository secret`) :

1. **DOCKER_USERNAME** : `yassinebrahimi`
2. **DOCKER_PASSWORD** : Votre mot de passe Docker Hub (ou Access Token Docker Hub)
3. **KUBECONFIG** : Le fichier d'authentification au cluster. Voici comment le configurer :
   - Connectez-vous à votre instance Master AWS via SSH.
   - Affichez le contenu du fichier k3s avec `sudo cat /etc/rancher/k3s/k3s.yaml`.
   - Copiez tout le texte généré.
   - Remplacez `https://127.0.0.1:6443` par l'adresse IP publique de l'instance Master (ex: `https://3.xx.xx.xx:6443`).
   - Collez ce contenu entier dans la valeur du secret `KUBECONFIG` sur GitHub.

## Monitoring
Pour déployer le monitoring (Prometheus/Grafana) :
```bash
kubectl apply -f monitoring/
```

## Auteurs
Projet Final : Master DSBD & IA
Date limite : 17 Mars (Réalisé le 23 Mars)
