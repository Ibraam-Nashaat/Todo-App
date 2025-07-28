# Todo App

A simple web-based Todo List app built with Node.js, Express, EJS, and MongoDB.  
This project is originally cloned from [https://github.com/Ankit6098/Todo-List-nodejs](https://github.com/Ankit6098/Todo-List-nodejs), but **the aim of this repository is to demonstrate DevOps concepts** including CI/CD, automated infrastructure provisioning, containerization, and GitOps deployment.

---

## Quick Start

1. **Generate SSH keys (required for Ansible):**
   ```
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   # This creates ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
   ssh-copy-id <user>@<remote-host-ip>
   ```

2. **Create `inventory.ini` for Ansible on your local machine:** 
   ```
   [devvm]
   vm1 ansible_host=<VM_IP> ansible_user=<VM_USER> ansible_ssh_private_key_file=~/.ssh/id_rsa

   [devvm:vars]
   VM_USER=<your-vm-username>
   ```

3. **Create `.env` file:**  
   Add your MongoDB connection string and VM user:
   ```
   MONGODB_URL=mongodb://<your-mongodb-url>
   VM_USER=<your-vm-username>
   ```

4. **Install Ansible on your local machine:**
   ```
   sudo apt update && sudo apt install ansible -y
   ```

---

## Running Ansible Playbooks on Local Machine

- **Docker Setup:**  
  ```
  export $(grep -v '^#' .env | xargs)
  ansible-playbook -i inventory.ini docker-setup.yml --ask-become-pass
  ```
  Installs Docker, Docker Compose, copies config files, and starts the app via Docker Compose.

- **Kubernetes & ArgoCD Setup:**  
  ```
  export $(grep -v '^#' .env | xargs)
  ansible-playbook -i inventory.ini kubernetes-setup.yml --ask-become-pass
  ```
  Installs Docker, K3s (Kubernetes), kubectl, ArgoCD, and sets up the environment.

---

## GitHub Actions & Secrets

- **Required secrets for `.github/workflows/release-docker.yml`:**
  - `GHCR_USERNAME` — Your GitHub username
  - `GHCR_TOKEN` — GitHub token with `packages:write` permission
  - `GITHUB_TOKEN` — Default GitHub Actions token

This workflow builds and pushes Docker images to GitHub Container Registry and updates the Kubernetes deployment manifest.

---

## Kubernetes & ArgoCD Deployment on VM

1. **Create Kubernetes secret from `.env`:**
   ```
   sudo kubectl create secret generic todo-env --from-env-file=.env
   ```

2. **Apply ArgoCD Application manifest:**
   ```
   sudo kubectl apply -f <path-to-file>/argocd-app.yml
   ```

3. **Access ArgoCD UI:**
   ```
   sudo kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
   Then open [https://localhost:8080](https://localhost:8080) in your browser.

---

## File Descriptions

- **Dockerfile:**  
  Builds an image for the Todo app.

- **docker-compose.yml:**  
  Defines services for the app and Watchtower (auto-updates containers on new image push).

- **docker-setup.yml (Ansible):**  
  Installs Docker, Docker Compose, copies config files, and runs the app on the VM.

- **kubernetes-setup.yml (Ansible):**  
  Installs Docker, K3s, kubectl, ArgoCD, and deploys ArgoCD on the VM.

- **k8s/base/deployment.yaml:**  
  Kubernetes deployment for the Todo app, uses image from GitHub Container Registry, references secret for environment variables.

- **k8s/base/service.yaml:**  
  Exposes the app via NodePort on port 4000.

- **k8s/base/kustomization.yaml:**  
  Kustomize manifest to manage deployment and service.

- **k8s/argocd-app.yml:**  
  ArgoCD Application manifest to automate deployment from the repo.

- **release-docker.yml (GitHub Actions):**  
  CI workflow to build, tag, and push Docker images, and update Kubernetes manifests.

---

## Additional Notes

- **Watchtower** is used for automatic Docker image updates on the VM.
- **ArgoCD** enables GitOps-based continuous deployment for Kubernetes.
- **Healthchecks** are configured in Docker Compose and Kubernetes for reliability.
- **SSH keys** are required for Ansible to connect to the VM.
- **All environment variables** should be set in `.env` and referenced in secrets for Kubernetes.

