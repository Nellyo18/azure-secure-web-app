# Secure Azure Web Application

## Azure Cloud Engineering & Security Portfolio Project

A production-inspired Microsoft Azure environment demonstrating hands-on skills in cloud infrastructure, administration, architecture, networking, identity, security, automation, application hosting, and monitoring.

This project deploys a Python Flask web application to Azure App Service and securely integrates it with Azure SQL Database and Azure Key Vault. The environment uses Azure Virtual Network integration, Private Endpoints, Private DNS, Microsoft Entra ID, Managed Identity, role-based access control (RBAC), GitHub Actions with OpenID Connect (OIDC), Application Insights, Log Analytics, Azure Monitor, and Microsoft Defender for Cloud.

The project was designed not only to deploy a working application, but to demonstrate how Azure services can be architected, administered, secured, monitored, and automated using cloud best practices.

## Career Skills Demonstrated

This project demonstrates hands-on skills applicable to:

- **Cloud Engineer** — Azure resource deployment, networking, PaaS integration, identity, monitoring, troubleshooting, and CI/CD
- **Cloud Administrator** — resource management, RBAC, monitoring, configuration, networking, access control, and operational troubleshooting
- **Cloud Architect** — solution design, network segmentation, service integration, private connectivity, identity architecture, availability considerations, and security design
- **Cloud Security Engineer** — least privilege, Managed Identity, Private Endpoints, secrets management, security monitoring, CSPM, and secure CI/CD

## Project Objectives

The primary objectives of this project are to:

- Design a secure Azure cloud architecture using multiple integrated Azure services
- Deploy and administer a Python web application using Azure App Service
- Design a segmented virtual network using dedicated Azure subnets
- Integrate Azure PaaS services using VNet Integration and Private Endpoints
- Implement private DNS resolution for privately connected Azure services
- Secure Azure SQL Database and Azure Key Vault from unnecessary public network access
- Implement passwordless service-to-service authentication using Managed Identity
- Apply least-privilege authorization using Azure RBAC and SQL database roles
- Implement CI/CD using GitHub Actions and OpenID Connect (OIDC)
- Monitor application performance and requests using OpenTelemetry and Application Insights
- Centralize telemetry and analyze events using Log Analytics and KQL
- Detect repeated HTTP failures using Azure Monitor alert rules
- Deliver automated security and operational notifications using Azure Monitor Action Groups
- Assess cloud security posture using Microsoft Defender for Cloud
- Evaluate resources against the Microsoft Cloud Security Benchmark
- Document and automate the infrastructure using Infrastructure as Code

## Solution Architecture

The solution uses Azure Platform as a Service (PaaS) components combined with private networking, identity-based authentication, CI/CD automation, and centralized monitoring.

The architecture separates application hosting, private backend connectivity, identity, deployment automation, and observability into distinct layers.

### Architecture Highlights

- Azure App Service hosts the Python Flask application.
- Azure Virtual Network Integration provides outbound connectivity from App Service into the virtual network.
- Dedicated subnets separate application integration, private endpoints, and management resources.
- Azure SQL Database is accessed through a Private Endpoint.
- Azure Key Vault is accessed through a Private Endpoint.
- Private DNS zones provide name resolution for privately connected Azure services.
- Microsoft Entra Managed Identity provides passwordless runtime authentication.
- Azure RBAC and SQL database roles enforce least-privilege authorization.
- GitHub Actions provides automated application deployment.
- OpenID Connect (OIDC) provides passwordless authentication between GitHub Actions and Azure.
- Application Insights and OpenTelemetry collect application telemetry.
- Log Analytics centralizes telemetry for analysis using KQL.
- Azure Monitor detects repeated HTTP errors and sends notifications through an Action Group.
- Microsoft Defender for Cloud provides cloud security posture management using Foundational CSPM and the Microsoft Cloud Security Benchmark.

### Architecture Diagram

![Secure Azure Web Application Architecture](docs/architecture.png)

## Identity & Access Management

The solution uses Microsoft Entra ID and managed identities to minimize the use of stored credentials and implement least-privilege access.

### Application Runtime Identity

Azure App Service uses a **system-assigned managed identity** to authenticate to backend Azure services.

The application requests Microsoft Entra ID access tokens at runtime instead of storing database passwords or service credentials in the application code.

The managed identity is used to access:

- **Azure SQL Database** using Microsoft Entra authentication
- **Azure Key Vault** using Azure RBAC

For Azure SQL Database, the App Service managed identity is configured as a database user and granted only the permissions required by the application:

- `db_datareader`
- `db_datawriter`

The application is not granted `db_owner`.

For Azure Key Vault, the App Service managed identity is assigned the:

- `Key Vault Secrets User`

role at the Key Vault scope.

This allows the application to retrieve secrets while preventing unnecessary secret-management permissions.

### CI/CD Identity

GitHub Actions uses **OpenID Connect (OIDC)** and Microsoft Entra workload identity federation to authenticate to Azure.

This eliminates the need to store a long-lived Azure client secret in the GitHub repository.

The deployment identity is granted:

- `Website Contributor`

scoped to the Azure App Service.

This separates deployment permissions from the application's runtime permissions.

### Identity Architecture

Two separate identities are intentionally used:

| Identity | Purpose | Access |
|---|---|---|
| GitHub federated identity | CI/CD deployment | Deploy application to Azure App Service |
| App Service system-assigned managed identity | Application runtime | Access Azure SQL Database and Azure Key Vault |

Separating deployment and runtime identities reduces privilege exposure and follows the principle of least privilege.

## Infrastructure as Code with Terraform

The Azure environment was initially built and validated through the Azure portal, then brought under Infrastructure as Code management using Terraform.

Rather than recreating the environment, the existing Azure resources were imported into Terraform state and reconciled against the Terraform configuration. Each proposed change was reviewed before allowing Terraform to manage the infrastructure.

### Terraform-Managed Infrastructure

Terraform configuration is located under:

```text
infra/terraform/

## Security Controls

Security was incorporated throughout the architecture rather than added only after deployment.

### Network Security

- Azure SQL Database uses a Private Endpoint.
- Azure Key Vault uses a Private Endpoint.
- Public network access is disabled for backend services during normal operation.
- Private DNS zones provide name resolution for Private Link resources.
- Dedicated subnets separate application integration, private endpoints, and management resources.
- Network Security Groups are used to define network traffic controls.

### Identity Security

- Microsoft Entra ID provides centralized identity.
- Managed Identity eliminates stored runtime credentials.
- GitHub Actions uses OIDC instead of a long-lived Azure client secret.
- Azure RBAC implements least-privilege access.
- SQL database permissions are limited to required read/write roles.

### Secrets Management

Azure Key Vault provides centralized secrets management.

The Flask application retrieves secrets at runtime using its managed identity instead of embedding secrets directly in source code.

### Security Posture Management

Microsoft Defender for Cloud Foundational CSPM is enabled with full monitoring coverage.

The **Microsoft Cloud Security Benchmark (MCSB)** is enabled at the subscription level to provide security posture assessments and recommendations.

Paid Defender workload protection plans were intentionally not enabled for this lab to maintain cost control while retaining foundational CSPM capabilities.

## CI/CD and Deployment Automation

Application deployment is automated using **GitHub Actions**.

Changes committed to the `main` branch can trigger the deployment workflow, allowing application updates to be deployed consistently to Azure App Service.

### Deployment Flow

The CI/CD process follows this general flow:

1. Application code is stored in GitHub.
2. GitHub Actions starts the deployment workflow.
3. GitHub authenticates to Microsoft Entra ID using OpenID Connect (OIDC).
4. Microsoft Entra ID validates the configured federated credential.
5. The GitHub deployment identity receives temporary Azure credentials.
6. GitHub Actions deploys the Python Flask application to Azure App Service.

This approach avoids storing a long-lived Azure client secret in GitHub.

### Workload Identity Federation

A user-assigned managed identity is used as the deployment identity for GitHub Actions.

A federated identity credential establishes trust between:

- Microsoft Entra ID
- The GitHub repository
- The `main` branch

The federated identity uses the audience:

`api://AzureADTokenExchange`

The deployment identity is assigned the `Website Contributor` role at the App Service scope, limiting its Azure permissions to those required for application deployment.

### Separation of Responsibilities

CI/CD authentication and application runtime authentication use separate identities.

GitHub Actions uses a federated deployment identity to deploy the application, while Azure App Service uses its system-assigned managed identity to access Azure SQL Database and Azure Key Vault at runtime.

This separation reduces the permissions associated with each identity and limits the impact of credential or identity compromise.

## Troubleshooting and Engineering Challenges

Building the environment required troubleshooting several real-world cloud integration issues.

### GitHub Actions OIDC Federation

#### Problem

Azure Deployment Center initially failed to configure GitHub Actions authentication and could not verify how GitHub issued OIDC tokens for the repository.

#### Investigation

The deployment identity had been created in Azure, but the required federated identity credential was not configured.

Without the federated credential, Microsoft Entra ID could not establish trust with GitHub Actions.

#### Resolution

A federated identity credential was manually configured for the GitHub repository and `main` branch using the Azure AD token exchange audience.

After establishing the federated trust relationship, Azure Deployment Center successfully configured the GitHub Actions workflow and deployments completed successfully.

#### Lesson Learned

OIDC authentication depends on a trust relationship between the external workload and Microsoft Entra ID. The identity existing in Azure is not sufficient by itself; the token issuer, subject, and audience must match the configured federated credential.

### Application Insights Request Telemetry

#### Problem

Application Insights initially displayed dependency telemetry, but incoming Flask HTTP requests were not appearing in the `AppRequests` table in Log Analytics.

#### Investigation

The Azure Monitor OpenTelemetry configuration was initialized after Flask had already been imported and the application object had been created.

Because Flask auto-instrumentation depends on initialization order, incoming request instrumentation was not being applied correctly.

#### Resolution

Azure Monitor OpenTelemetry was configured before importing and initializing Flask.

The application initialization order was changed so that:

1. Azure Monitor OpenTelemetry is configured.
2. Flask is imported.
3. The Flask application is created.
4. Application routes are initialized.

After redeployment, incoming requests appeared successfully in the `AppRequests` table.

#### Verification

The following application routes generated request telemetry:

- `/`
- `/database`
- `/messages`
- `/keyvault`

Request data could then be analyzed using KQL in Log Analytics.

## Monitoring, Logging & Alerting

The environment implements centralized application monitoring and automated alerting using Azure-native observability services.

### Monitoring Architecture

Application telemetry follows this flow:

`Python Flask → OpenTelemetry → Application Insights → Log Analytics → Azure Monitor → Action Group → Email Notification`

### OpenTelemetry and Application Insights

The Python Flask application uses the Azure Monitor OpenTelemetry distribution to automatically collect application telemetry.

Application Insights provides visibility into:

- HTTP requests
- Request response times
- HTTP status codes
- Application dependencies
- Azure SDK operations
- Application failures

Telemetry is sent to the Log Analytics workspace for centralized analysis.

### Log Analytics and KQL

Kusto Query Language (KQL) is used to analyze application request telemetry.

For example, the following query identifies HTTP requests that failed or returned an HTTP status code of 400 or greater:

```kusto
AppRequests
| where TimeGenerated > ago(24h)
| where Success == false or toint(ResultCode) >= 400
| project TimeGenerated, Name, Url, ResultCode, DurationMs
| order by TimeGenerated desc
#### Lesson Learned

Application observability can depend on initialization order. Successful dependency telemetry does not necessarily mean that request-level instrumentation is configured correctly.

## Application & Data Layer

The application is a Python Flask web application hosted on Azure App Service.

The application provides several routes that demonstrate integration with Azure services:

| Route | Purpose |
|---|---|
| `/` | Application home page |
| `/database` | Tests passwordless connectivity to Azure SQL Database |
| `/messages` | Retrieves messages stored in Azure SQL Database |
| `/add-message` | Inserts a message into Azure SQL Database using parameterized SQL |
| `/keyvault` | Demonstrates secure retrieval of a secret from Azure Key Vault |

### Azure SQL Database

Application data is stored in Azure SQL Database.

The database contains a `Messages` table used to demonstrate application read/write operations.

The Flask application does not use a traditional SQL username and password. Instead, the App Service system-assigned managed identity requests a Microsoft Entra access token for Azure SQL Database.

The managed identity is granted only:

- `db_datareader`
- `db_datawriter`

This allows the application to perform required database operations without receiving administrative database privileges.

### Azure Key Vault

Azure Key Vault provides centralized secrets management.

The Flask application authenticates to Key Vault using its system-assigned managed identity and retrieves secrets using the Azure SDK.

The application therefore does not require Key Vault credentials to be embedded in source code.

Both Azure SQL Database and Azure Key Vault normally have public network access disabled and are reached through Private Endpoints.
