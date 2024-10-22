BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

export REGION_1=${ZONE::-2}

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Create VPC networks and subnets
gcloud compute networks create managementnet --subnet-mode=custom
gcloud compute networks subnets create managementsubnet-1-$REGION --network=managementnet --region=$REGION --range=10.130.0.0/20

gcloud compute networks create privatenet --subnet-mode=custom
gcloud compute networks subnets create privatesubnet-1-$REGION --network=privatenet --region=$REGION --range=172.16.0.0/24
gcloud compute networks subnets create privatesubnet-2-$REGION --network=privatenet --region=$REGION --range=172.20.0.0/20

# Create firewall rules
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=managementnet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

# Create instances
gcloud compute instances create managementnet-vm-1 --zone=$ZONE --machine-type=e2-micro --subnet=managementsubnet-1-$REGION

gcloud compute instances create privatenet-vm-1 --zone=$ZONE --machine-type=e2-micro --subnet=privatesubnet-1-$REGION

# Create VPC peering
gcloud compute network-peerings create peering-management-private \
  --network=managementnet \
  --peer-network=privatenet \
  --export-routes-to-peer=ENABLE \
  --import-routes-from-peer=ENABLE

# Create an instance with multiple network interfaces
gcloud compute instances create vm-appliance \
  --zone=$ZONE \
  --machine-type=e2-standard-4 \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=managementsubnet-1-$REGION \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=privatesubnet-1-$REGION \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#