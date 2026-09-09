# Secure Azure Web Application

A cloud security portfolio project demonstrating the design, deployment, and security of a Python Flask web application on Microsoft Azure.

The application is hosted on Azure App Service and integrates securely with Azure SQL Database and Azure Key Vault using private networking and passwordless authentication. The environment also implements CI/CD with GitHub Actions and OpenID Connect (OIDC), centralized application monitoring with Azure Monitor and Application Insights, and automated HTTP error alerting.

## Project Objectives

The goal of this project is to build a production-inspired Azure environment while applying cloud security best practices, including:

- Network segmentation using Azure Virtual Network and dedicated subnets
- Private connectivity to Azure SQL Database and Azure Key Vault using Private Endpoints
- Private DNS resolution for Azure PaaS resources
- Passwordless authentication using Microsoft Entra ID and Managed Identity
- Least-privilege access using Azure RBAC and SQL database roles
- Secure CI/CD authentication using GitHub Actions and OIDC
- Application monitoring using OpenTelemetry and Application Insights
- Centralized logging and KQL analysis using Log Analytics
- Automated detection and email alerting using Azure Monitor
- Cloud security posture assessment using Microsoft Defender for Cloud and the Microsoft Cloud Security Benchmark
