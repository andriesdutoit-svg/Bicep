# Azure Multi-Region AD Lab (Bicep)

## Overview

This project deploys a **multi-region Azure lab environment** using Bicep.  
It includes:

- Multiple Virtual Networks (VNets)
- Full mesh VNet peering
- Distributed Domain Controllers
- Windows client VMs
- Ubuntu Linux VMs
- Network Security Groups with controlled internal and optional external access

The design is **fully parameter-driven**, allowing easy scaling and reconfiguration.

---

## Architecture

### Infrastructure Layer

The following components are created dynamically based on the `regions` parameter:

- Resource Groups (per region)
- VNets (per region)
- Subnets (per VNet)

### Peering
- Manual VNet peering

### Workload Layer

Virtual machines are explicitly placed into regions:

- 5 Domain Controllers
- 2 Windows client VMs
- 2 Ubuntu Linux VMs

---

## Regions

Defined in `main.parameters.json`:

```json
"regions": {
  "wus2": "westus2",
  "krc": "koreacentral",
  "sdc": "swedencentral",
  "we": "westeurope",
  "ae": "australiaeast"
}