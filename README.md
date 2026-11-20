\# Multi-Site Automated and Highly Available Platform



\## 1. Project Overview



This project demonstrates a simulated multi-site infrastructure connecting three locations: Lahore, Islamabad, and Karachi.



The platform uses Docker networking to establish communication between sites and Kubernetes to deploy and manage containerized applications. A PowerShell automation script is included to simplify network deployment.



\## 2. Project Objectives



\- Build a multi-site network environment.

\- Establish communication between different site networks.

\- Automate network deployment using PowerShell.

\- Deploy containerized applications using Kubernetes.

\- Configure services for application access.

\- Demonstrate Kubernetes self-healing through pod recreation.



\## 3. Technologies Used



| Technology | Purpose |

|---|---|

| Docker Desktop | Container management |

| Docker Bridge Networks | Site network simulation |

| Alpine Linux | Central routing container |

| Nginx | Web application |

| Kubernetes | Container orchestration |

| PowerShell | Deployment automation |

| Git | Version control |



\## 4. Network Architecture



The project simulates three geographically separate sites.



| Site | Network | Server IP | Router IP |

|---|---|---|---|

| Lahore | 10.10.1.0/24 | 10.10.1.10 | 10.10.1.254 |

| Islamabad | 10.10.2.0/24 | 10.10.2.10 | 10.10.2.254 |

| Karachi | 10.10.3.0/24 | 10.10.3.10 | 10.10.3.254 |



A central Alpine Linux container acts as the router between all three Docker networks. IP forwarding and static routes enable inter-site communication.



\## 5. Network Automation



The PowerShell script:



`automation/deploy-network.ps1`



Automates the creation and configuration of:



\- Three Docker bridge networks.

\- Three Nginx site servers.

\- One central router.

\- Router network connections.

\- IP forwarding and static routes.



Run the script using:



```powershell

powershell -ExecutionPolicy Bypass -File .\\automation\\deploy-network.ps1

```



\## 6. Kubernetes Deployment



A Kubernetes namespace named `multi-site` contains three application deployments:



\- Lahore Application

\- Islamabad Application

\- Karachi Application



Each deployment runs two Nginx replicas.



The project uses NodePort services to expose the applications.



| Application | Replicas | NodePort |

|---|---:|---:|

| Lahore | 2 | 30110 |

| Islamabad | 2 | 31663 |

| Karachi | 2 | 30183 |



All Kubernetes resources are defined declaratively in:



`kubernetes/sites.yaml`



Deploy the configuration using:



```powershell

kubectl apply -f .\\kubernetes\\sites.yaml

```



Verify deployments and services:



```powershell

kubectl get deployments,services -n multi-site

```



\## 7. Application Access



Applications can be accessed locally through Kubernetes port forwarding.



Example for Lahore:



```powershell

kubectl port-forward service/lahore-service 8080:80 -n multi-site

```



Open the following address in a browser:



`http://localhost:8080`



\## 8. Testing and Verification



The following tests were successfully performed:



\- Inter-site connectivity between Docker networks.

\- HTTP communication between site servers.

\- Router IP forwarding.

\- Kubernetes deployment readiness.

\- Six running application pods.

\- Three Kubernetes NodePort services.

\- Nginx web application access through port forwarding.

\- Kubernetes self-healing by deleting a pod and observing its automatic recreation.



\## 9. Project Structure



```text

multi-site-platform/

│

├── automation/

│   └── deploy-network.ps1

│

├── kubernetes/

│   └── sites.yaml

│

├── networking/

├── applications/

├── infrastructure/

├── documentation/

│

└── README.md

```



\## 10. Current Limitations



\- The three sites are simulated using Docker bridge networks rather than physical geographic infrastructure.

\- The Kubernetes environment currently uses a single-node cluster.

\- The network uses one central router, without router redundancy.

\- Production-grade multi-site high availability and disaster recovery have not yet been implemented.



\## 11. Conclusion



This project demonstrates the fundamentals of multi-site network simulation, automated infrastructure deployment, container orchestration, service exposure, and Kubernetes self-healing.



It provides a foundation for extending the platform toward a more resilient and production-oriented architecture.

