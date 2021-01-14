##########################################
#  VARIABLES                             #
##########################################
monaco_version="v1.1.0" 
source_repo="https://github.com/dynatrace-ace/perform2021-vhot-monaco" 
clone_folder="bootstrap"
domain="nip.io"
jenkins_chart_version="1.27.0"
git_org="perform"
git_repo="perform"
git_user="dynatrace"
git_pwd="dynatrace"
git_email="perform2021@dt-perform.com"
shell_user="dtu_training"

# These need to be set as environment variables prior to launching the script
#export DYNATRACE_ENVIRONMENT_ID=     # only the environmentid (abc12345) is needed. script assumes a sprint tenant 
#export DYNATRACE_TOKEN=              # for Perform vHOT we get a token that is both an API and PaaS token

##########################################
#  DO NOT MODIFY ANYTHING IN THIS SCRIPT #
##########################################

home_folder="/home/$shell_user"

echo "Installing packages"
sudo snap install jq

echo "Retrieving Dynatrace Environment details"
# Retrieve token  management token
# Comes from pipeline as $DYNATRACE_TOKEN

# Retrieve environment. Available from DTU pipeline as $DYNATRACE_ENVIRONMENT_ID
# DT_TENANT MUST be set without leading https:// or trailing slashes
DT_TENANT=https://$DYNATRACE_ENVIRONMENT_ID.sprint.dynatracelabs.com

VM_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Virtual machine IP: $VM_IP"

ingress_domain="$VM_IP.$domain"
echo "Ingress domain: $ingress_domain"

cd 

##############################
# Download Monaco + add PATH #
##############################
wget https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/releases/download/v1.0.1/monaco-linux-amd64 -O $home_folder/monaco
chmod +x $home_folder/monaco
cp $home_folder/monaco /usr/local/bin

##############################
# Clone repo                 #
##############################
cd $home_folder
mkdir "$clone_folder"
cd "$home_folder/$clone_folder"
git clone "$source_repo" .
chown -R $shell_user $home_folder/$clone_folder

##############################
# Install k3s and Helm       #
##############################

echo "Installing k3s"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.18.3+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik
echo "Waiting 30s for kubernetes nodes to be available..."
sleep 30
# Use k3s as we haven't setup kubectl properly yet
k3s kubectl wait --for=condition=ready nodes --all --timeout=60s
# Force generation of $home_folder/.kube
kubectl get nodes
# Configure kubectl so we can use "kubectl" and not "k3 kubectl"
cp /etc/rancher/k3s/k3s.yaml $home_folder/.kube/config
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "Installing Helm"
sudo snap install helm --classic
helm repo add stable https://charts.helm.sh/stable
helm repo add incubator https://charts.helm.sh/incubator

##############################
# Install Dynatrace OneAgent #
##############################
echo "Dynatrace OneAgent - Install"
kubectl create namespace dynatrace
helm repo add dynatrace https://raw.githubusercontent.com/Dynatrace/helm-charts/master/repos/stable
sed \
    -e "s|DYNATRACE_ENVIRONMENT_PLACEHOLDER|$DT_TENANT|"  \
    -e "s|DYNATRACE_TOKEN_PLACEHOLDER|$DYNATRACE_TOKEN|g"  \
    $home_folder/$clone_folder/box/helm/oneagent-values.yml > $home_folder/$clone_folder/box/helm/oneagent-values-gen.yml

helm install dynatrace-oneagent-operator dynatrace/dynatrace-oneagent-operator -n dynatrace --values $home_folder/$clone_folder/box/helm/oneagent-values-gen.yml --wait

# Wait for Dynatrace pods to signal Ready
echo "Dynatrace OneAgent - Waiting for Dynatrace resources to be available..."
kubectl wait --for=condition=ready pod --all -n dynatrace --timeout=60s

##############################
# Install ingress-nginx      #
##############################

echo "Installing ingress-nginx"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace --wait

##############################
# Install Gitea + config     #
##############################

echo "Gitea - Install using Helm"
helm repo add k8s-land https://charts.k8s.land

sed \
    -e "s|INGRESS_PLACEHOLDER|$ingress_domain|"  \
    $home_folder/$clone_folder/box/helm/gitea-values.yml > $home_folder/$clone_folder/box/helm/gitea-values-gen.yml

helm install gitea k8s-land/gitea -f $home_folder/$clone_folder/box/helm/gitea-values-gen.yml --namespace gitea --create-namespace

kubectl -n gitea rollout status deployment gitea-gitea
echo "Gitea - Sleeping for 60s"
sleep 60

echo "Gitea - Create initial user $git_user"
kubectl exec -t $(kubectl -n gitea get po -l app=gitea-gitea -o jsonpath='{.items[0].metadata.name}') -n gitea -- bash -c 'su - git -c "/usr/local/bin/gitea --custom-path /data/gitea --config /data/gitea/conf/app.ini  admin create-user --username '$git_user' --password '$git_pwd' --email '$git_email' --admin --access-token"' > gitea_install.txt

gitea_pat=$(grep -oP 'Access token was successfully created... \K(.*)' gitea_install.txt)

echo "Gitea - PAT: $gitea_pat"
echo "Gitea - URL: http://gitea.$ingress_domain"

ingress_domain=$ingress_domain gitea_pat=$gitea_pat bash -c 'while [[ "$(curl -s -o /dev/null -w "%{http_code}" http://gitea.$ingress_domain/api/v1/admin/orgs?access_token=$gitea_pat)" != "200" ]]; do sleep 5; done'

echo "Gitea - Create org $git_org..."
curl -k -d '{"full_name":"'$git_org'", "visibility":"public", "username":"'$git_org'"}' -H "Content-Type: application/json" -X POST "http://gitea.$ingress_domain/api/v1/orgs?access_token=$gitea_pat"
echo "Gitea - Create repo $git_repo..."
curl -k -d '{"name":"'$git_repo'", "private":false, "auto-init":true}' -H "Content-Type: application/json" -X POST "http://gitea.$ingress_domain/api/v1/org/$git_org/repos?access_token=$gitea_pat"
echo "Gitea - Git config..."
git config --global user.email "$git_email" && git config --global user.name "$git_user" && git config --global http.sslverify false
cd $home_folder
echo "Gitea - Adding resources to repo $git_org/$git_repo"
git clone http://$git_user:$gitea_pat@gitea.$ingress_domain/$git_org/$git_repo
cp -r $home_folder/$clone_folder/box/repo/. $home_folder/$git_repo
cd $home_folder/$git_repo && git add . && git commit -m "Initial commit, enjoy"
cd $home_folder/$git_repo && git push http://$git_user:$gitea_pat@gitea.$ingress_domain/$git_org/$git_repo


##############################
# Install ActiveGate         #
##############################

echo "Dynatrace ActiveGate - Download"
activegate_download_location=$home_folder/Dynatrace-ActiveGate-Linux-x86-latest.sh
if [ ! -f "$activegate_download_location" ]; then
    echo "$activegate_download_location does not exist. Downloading now..."
    wget "$DT_TENANT/api/v1/deployment/installer/gateway/unix/latest?arch=x86&flavor=default" --header="Authorization: Api-Token $DYNATRACE_TOKEN" -O $activegate_download_location 
fi
echo "Dynatrace ActiveGate - Install Private Synthetic"
#DYNATRACE_SYNTHETIC_AUTO_INSTALL=true /bin/sh "$activegate_download_location" --enable-synthetic


##############################
# Install Jenkins            #
##############################
echo "Jenkins - Install"
kubectl create ns jenkins
kubectl create -f $home_folder/$clone_folder/box/helm/jenkins-pvc.yml
sed \
    -e "s|GITHUB_USER_EMAIL_PLACEHOLDER|$git_email|" \
    -e "s|GITHUB_USER_NAME_PLACEHOLDER|$git_user|" \
    -e "s|GITHUB_PERSONAL_ACCESS_TOKEN_PLACEHOLDER|$gitea_pat|" \
    -e "s|GITHUB_ORGANIZATION_PLACEHOLDER|$git_org|" \
    -e "s|DT_TENANT_URL_PLACEHOLDER|$DT_TENANT|" \
    -e "s|DT_API_TOKEN_PLACEHOLDER|$DYNATRACE_TOKEN|" \
    -e "s|INGRESS_PLACEHOLDER|$ingress_domain|" \
    -e "s|GIT_REPO_PLACEHOLDER|$git_repo|" \
    -e "s|GIT_DOMAIN_PLACEHOLDER|gitea.$ingress_domain|" \
    $home_folder/$clone_folder/box/helm/jenkins-values.yml > $home_folder/$clone_folder/box/helm/jenkins-values-gen.yml

kubectl create clusterrolebinding jenkins --clusterrole cluster-admin --serviceaccount=jenkins:jenkins

helm install jenkins stable/jenkins --values $home_folder/$clone_folder/box/helm/jenkins-values-gen.yml --version $jenkins_chart_version --namespace jenkins --wait 

##############################
# Deploy App                 #
##############################
sed -e "s|INGRESS_PLACEHOLDER|$ingress_domain|g"  \
    $home_folder/$clone_folder/box/app-manifests/application-1.yml > $home_folder/$clone_folder/box/app-manifests/application-1-gen.yml

sed -e "s|INGRESS_PLACEHOLDER|$ingress_domain|g"  \
    $home_folder/$clone_folder/box/app-manifests/application-2.yml > $home_folder/$clone_folder/box/app-manifests/application-2-gen.yml

sed -e "s|INGRESS_PLACEHOLDER|$ingress_domain|g"  \
    $home_folder/$clone_folder/box/app-manifests/application-3.yml > $home_folder/$clone_folder/box/app-manifests/application-3-gen.yml

kubectl apply -f $home_folder/$clone_folder/box/app-manifests/application-1-gen.yml
kubectl apply -f $home_folder/$clone_folder/box/app-manifests/application-2-gen.yml
kubectl apply -f $home_folder/$clone_folder/box/app-manifests/application-3-gen.yml

sed \
    -e "s|INGRESS_PLACEHOLDER|$ingress_domain|g" \
    -e "s|GITEA_USER_PLACEHOLDER|$git_user|g" \
    -e "s|GITEA_PAT_PLACEHOLDER|{{ $gitea_pat|g" \
    -e "s|DYNATRACE_TENANT_PLACEHOLDER|$DT_TENANT|g"\
    /vagrant/docker/dashboard/index.html > /vagrant/docker/dashboard/index-gen.html



# Deploy Customers A, B and C
#echo "Deploying customer resources..."
#kubectl apply -f deploy-customer-a.yaml -f deploy-customer-b.yaml -f deploy-customer-c.yaml

# Deploy Istio Gateway
# #kubectl apply -f istio-gateway.yaml

# # Deploy Production Istio VirtualService
# # Provides routes to customers from http://customera.VMIP.nip.io, http://customerb.VMIP.nip.io and http://customerc.VMIP.nip.io
# sed -i "s@- \"customera.INGRESSPLACEHOLDER\"@- \"customera.$VM_IP.nip.io\"@g" production-istio-vs.yaml
# sed -i "s@- \"customerb.INGRESSPLACEHOLDER\"@- \"customerb.$VM_IP.nip.io\"@g" production-istio-vs.yaml
# sed -i "s@- \"customerc.INGRESSPLACEHOLDER\"@- \"customerc.$VM_IP.nip.io\"@g" production-istio-vs.yaml
# kubectl apply -f production-istio-vs.yaml

# # Deploy Staging Istio VirtualService
# # Provides routes to customers from http://staging.customera.VMIP.nip.io, http://staging.customerb.VMIP.nip.io and http://staging.customerc.VMIP.nip.io
# sed -i "s@- \"staging.customera.INGRESSPLACEHOLDER\"@- \"staging.customera.$VM_IP.nip.io\"@g" staging-istio-vs.yaml
# sed -i "s@- \"staging.customerb.INGRESSPLACEHOLDER\"@- \"staging.customerb.$VM_IP.nip.io\"@g" staging-istio-vs.yaml
# sed -i "s@- \"staging.customerc.INGRESSPLACEHOLDER\"@- \"staging.customerc.$VM_IP.nip.io\"@g" staging-istio-vs.yaml
# kubectl apply -f staging-istio-vs.yaml

# # Deploy Keptn Istio VirtualService
# # Provides routes to http://keptn.VMIP.nip.io/api and http://keptn.VMIP.nip.io/bridge
# sed -i "s@- \"keptn.INGRESSPLACEHOLDER\"@- \"keptn.$VM_IP.nip.io\"@g" keptn-vs.yaml
# kubectl apply -f keptn-vs.yaml

# # Authorise Keptn
# export KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
# export KEPTN_ENDPOINT=http://keptn.127.0.0.1.nip.io/api
# keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN

# # Configure Bridge Credentials
# keptn configure bridge --user=keptn --password=dynatrace

# # Allow Dynatrace access to create tags from labels and annotations in each NS
# kubectl -n customer-a create rolebinding default-view --clusterrole=view --serviceaccount=customer-a:default
# kubectl -n customer-b create rolebinding default-view --clusterrole=view --serviceaccount=customer-b:default
# kubectl -n customer-c create rolebinding default-view --clusterrole=view --serviceaccount=customer-c:default

# # Scale deployments to create tags from k8s labels (tags only created during pod startup)
# kubectl scale deployment staging-web -n customer-a --replicas=0 && kubectl scale deployment staging-web -n customer-a --replicas=1
# kubectl scale deployment prod-web -n customer-a --replicas=0 && kubectl scale deployment prod-web -n customer-a --replicas=1
# kubectl scale deployment staging-web -n customer-b --replicas=0 && kubectl scale deployment staging-web -n customer-b --replicas=1
# kubectl scale deployment prod-web -n customer-b --replicas=0 && kubectl scale deployment prod-web -n customer-b --replicas=1
# kubectl scale deployment staging-web -n customer-c --replicas=0 && kubectl scale deployment staging-web -n customer-c --replicas=1
# kubectl scale deployment prod-web -n customer-c --replicas=0 && kubectl scale deployment prod-web -n customer-c --replicas=1

# # Start Load Gen against customer sites
# echo "Starting Load Generator for Customers A, B & C"
# chmod +x $home_folder/apac-mac-hot/box/loadGen.sh
# nohup $home_folder/apac-mac-hot/box/loadGen.sh &
# echo

# # Print output
# echo "----------------------------" >> $home_folder/installOutput.txt
# echo "INSTALLATION COMPLETED" >> $home_folder/installOutput.txt
# echo "Customer A Staging Environment available at: http://staging.customera.$VM_IP.nip.io" >> $home_folder/installOutput.txt
# echo "Customer A Production Environment available at: http://customera.$VM_IP.nip.io" >> $home_folder/installOutput.txt
# echo "Customer B Staging Environment available at: http://staging.customerb.$VM_IP.nip.io" >> $home_folder/installOutput.txt
# echo "Customer B Production Environment available at: http://customerb.$VM_IP.nip.io" >> $home_folder/installOutput.txt
# echo "Customer C Staging Environment available at: http://staging.customerc.$VM_IP.nip.io" >> $home_folder/installOutput.txt
# echo "Customer C Production Environment available at: http://customerc.$VM_IP.nip.io" >> $home_folder/installOutput.txt
# echo "Keptn's API available at: http://keptn.$VM_IP.nip.io/api" >> $home_folder/installOutput.txt
# echo "Keptn's Bridge available at: http://keptn.$VM_IP.nip.io/bridge" >> $home_folder/installOutput.txt
# echo "Keptn's API Token: $KEPTN_API_TOKEN" >> $home_folder/installOutput.txt
# echo "Keptn's Bridge Username: keptn" >> $home_folder/installOutput.txt
# echo "Keptn's Bridge Password: dynatrace" >> $home_folder/installOutput.txt
# echo "----------------------------" >> $home_folder/installOutput.txt