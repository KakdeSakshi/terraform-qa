
terraform {
  backend "s3" {
    bucket         = "myawsbucket-1015"  # Replace with your actual S3 bucket name
    key            = "qa/terraform.tfstate"         # Path in the bucket where the state file is stored
    region         = "us-east-1"                    # Change this to your AWS region
    dynamodb_table = "terraform-lock"               # DynamoDB table to enable state locking
    encrypt        = true                           # Encrypts state file for security
    workspace_key_prefix = "workspaces"            # Enables Terraform workspaces for multiple environments
  }
}
