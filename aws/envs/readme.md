## Bring Your Own Environment
This readme outlines the needed infrastructure needed in a standard Chalk environment.

## Critical Infrastructure Components
1. AWS Account
   * General
     * AWS Account ID (eg. 123456789012)
     * AWS Region (eg. us-east-1)
   * VPC [[vpc.tf]](sample/vpc.tf)
     * VPC ID 
     * Subnet IDs
     * Private Subnet IDs
   * IAM
     * API Server Role ARN
     * SSL ACM Cert ARN
     * Secret KMS ARN [[kms.tf]](sample/kms.tf)
     * IAM Role For Backgroud Persistence
     * IAM Role For Feature Engines
   * Storage [[buckets.tf]](sample/buckets.tf)
     * Dataset Storage Bucket
     * Data ETL Bucket
     * Source Code Bucket
     * ECR Repository for Engine Images [[ecr.tf]](sample/ecr.tf)
2. Kubernetes
    * EKS Cluster [[eks.tf]](sample/eks.tf)
      * EKS Namespace for Workloads
      * EKS Namespace for Background Persistence
    * Via Helm
      * EKS Karpenter
      * EKS Keda
      * EBS CSI Driver
      * EKS ALB controller
3. Kafka
    * MSK Cluster [[msk.tf]](sample/msk.tf)
    * Credentials [[secrets.tf]](sample/secrets.tf)
      * Kafka Brokers 
      * Username
      * Password
4. Online Store [[online_store.tf]](sample/online_store.tf)
    * DynamoDB URI
5. RDS Postgres Metadata Database [[rds.tf]](sample/rds.tf)
    * RDS URI
    
