# Azure Multi-Region Lab (v1.5)

## Overview

This project deploys a multi-region Azure environment using Bicep, including networking, compute, and automated post-deployment validation.

Version 1.5 introduces a fully automated Infrastructure as Code (IaC) deployment, replacing the previously manual setup.

---

## Architecture

- 5 Azure regions
- Separate resource group per region
- One VNet per region
- Full mesh VNet peering (defined in Bicep)
- Domain Controllers, Windows clients, and Linux servers deployed across regions

---

## Key Features

### Infrastructure as Code
- Modular Bicep templates
- Subscription-level deployment
- Consistent naming and tagging strategy (`project=lab2`)

### Networking
- Multi-region VNet architecture
- Full mesh VNet peering (manually defined in Bicep)
- Network Security Groups configured for required traffic

### Compute
- Windows Server (Domain Controllers)
- Windows client VMs
- Ubuntu Linux servers

### Connectivity Enablement
- RDP (port 3389) enabled via NSGs

### Automated Connectivity Testing
- Windows VMs:
  - PowerShell test scripts
  - Output: `C:\temp\network-test.txt`
- Linux VMs:
  - `nc` (netcat) port testing
  - Output: `/tmp/network-test/network-test.txt`

Cross-VM connectivity is validated automatically after deployment.

---

## Deployment

```bash
az deployment sub create \
  --name lab2-v1-5 \
  --location westeurope \
  --template-file main.bicep \
  --parameters @main.parameters.json