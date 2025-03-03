
#terraform {
  #backend "s3" {
    #bucket         = "myawsbucket-1015"  
    #key            = "workspaces/${terraform.workspace}/terraform.tfstate"        
    
    #region         = "us-east-1"                    
    #dynamodb_table = "terraform-lock"              
   # encrypt        = true                           
  #  workspace_key_prefix = "workspaces"            
 # }
#}

