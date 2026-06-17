# Azure Multi-Region Active Directory Lab (Bicep)

## Overview

This project demonstrates the deployment of a multi-region Active Directory lab environment in Microsoft Azure using Infrastructure as Code (Bicep).

The solution focuses on:
- Multi-region network architecture
- Resilient identity infrastructure design
- Reusable and modular deployment patterns

---

## Architecture

### Regions
- West US 2 (WUS2)
- Korea South (KRS)
- Sweden Central (SDC)

### Networking
- One VNet per region
- Full mesh VNet peering
- Private communication over Azure backbone

### Domain Controllers
- 3x Windows Server VMs (one per region)
- Static IP addressing

### Clients
- 1x Windows client VM
- 1x Ubuntu Linux VM

---

## Features

- Fully automated deployment using Bicep
- Parameterized and reusable modules
- Multi-region architecture
- Full mesh VNet peering (bidirectional)
- NSG configuration for Active Directory traffic
- Static IP assignment for infrastructure roles
- Clean modular design (networking, compute, peering)

---

## Project Structure

```
azure-multi-region-ad-lab/
|
|-- main.bicep
|-- modules/
|   |-- networking/
|   |   |-- vnet.bicep
|   |-- compute/
|   |   |-- vm-windows.bicep
|   |   |-- vm-linux.bicep
|   |-- peering/
|       |-- peering.bicep
|
|-- README.md
```

---

## Deployment

### Prerequisites

- Azure CLI installed
- Logged into Azure:

```bash
az login
```

### Deploy the solution

```bash
az deployment sub create \
  --location westus2 \
  --template-file main.bicep \
  --parameters adminUsername=<username> adminPassword=<password>
```

---

## Parameters

- prefix: Naming prefix for resources
- regions: Azure regions used in deployment
- adminUsername: Local admin username
- adminPassword: Local admin password
- vmSize: Virtual machine size
- tags: Resource tags

---

## Networking Design

- VNets use private address spaces:
  - 10.0.0.0/16
  - 10.1.0.0/16
  - 10.2.0.0/16

- NSG allows required AD ports:
  - DNS (53)
  - Kerberos (88)
  - LDAP (389)
  - SMB (445)
  - RPC (135)
  - RDP (3389)
  - Dynamic RPC (49152–65535)

---

## Peering Design

- Automatic full mesh between all VNets
- Bidirectional peering enables:
  - Authentication flows
  - DNS resolution
  - Service discovery

---

## Key Concepts Demonstrated

- Infrastructure as Code (IaC)
- Modular Bicep design
- Azure networking fundamentals
- Multi-region architecture
- Identity platform foundation

---

## Notes

- This deployment only provisions infrastructure
- Active Directory configuration is performed manually
- No public IPs are deployed by default

---

## Future Enhancements

- Azure Bastion for secure access
- Automated AD DS deployment
- Domain join automation
- Microsoft Entra ID integration
- CI/CD using GitHub Actions

---

## Author

**Andries Du Toit**  
Windows Engineer (Secondment)  
Cape Town, South Africa
