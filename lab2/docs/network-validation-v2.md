\# ------------------------------------------------------------

\# PURPOSE:

\# Retrieve private IPs for all lab2 VMs and format them

\# for use in Bicep (vmIps variable)

\# ------------------------------------------------------------



\# Start all VMs



az vm list --query "\[?starts\_with(name,'lab2-')].id" -o tsv | ForEach-Object {

&#x20; az vm start --ids $\_

}



\# Step 1: Retrieve VM names and private IPs from Azure

$vms = az vm list-ip-addresses `

&#x20; --query "\[].{name:virtualMachine.name, ip:virtualMachine.network.privateIpAddresses\[0]}" `

&#x20; -o json | ConvertFrom-Json



\# Step 2: Create an empty mapping object

$vmIps = @{}



\# Step 3: Filter only lab2 VMs and build the mapping

foreach ($vm in $vms) {

&#x20;   if ($vm.name -like "lab2-\*") {



&#x20;       # Remove "lab2-" prefix from VM name

&#x20;       $name = $vm.name.Replace("lab2-","")



&#x20;       # Assign private IP to cleaned name

&#x20;       $vmIps\[$name] = $vm.ip

&#x20;   }

}



\# Step 4: Output mapping in JSON format

\# This is used as intermediate output before converting to Bicep

$vmIps | ConvertTo-Json -Depth 3



\## Example Output



{

&#x20; "dc01": "10.0.0.4",

&#x20; "dc02": "10.1.0.4",

&#x20; "dc03": "10.2.0.4",

}



\## Convert to Bicep format



var vmIps = {

&#x20; dc01: '10.0.0.4'

&#x20; dc02: '10.1.0.4'

&#x20; dc03: '10.2.0.4'

}

