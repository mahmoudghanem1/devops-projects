# Project 01 – AWS 3-Tier Architecture (Terraform)

This project demonstrates building a highly available **network foundation** on AWS using **Terraform**.

---

## Architecture Overview

The following components were implemented:

- Two VPCs
- Public and Private Subnets across multiple Availability Zones
- Internet Gateway
- NAT Gateways
- Route Tables with proper associations
- Fully provisioned using Terraform modules

---

## What Was Implemented

- VPC networking design
- Subnet segmentation (public / private)
- Internet access for public subnets
- Outbound internet access for private subnets via NAT Gateway
- Clean and reusable Terraform structure

---

## Tools Used

- AWS
- Terraform
- VS Code

---

## Screenshots

Infrastructure proof is available in the following directory:

docs/screenshots/

Included screenshots:
- Terraform apply success
- VPCs created
- Public and private subnets
- Route tables
- Resource map
- NAT gateways


---

## Status

✅ Network layer completed  
🚧 Application layer in progress
