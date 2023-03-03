terraform {
  cloud {
    organization = "Exe-01"

    workspaces {
      name = "aulas_mack"
    }
  }
}

provider "aws" {
	region = "us-east-1"
  access_key = "AKIAXOAG527EP7XV6RGB"
  secret_key = "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"
}

provider "aws" {
	region = "sa-east-1"
  alias  = "brasil"
  access_key = "AKIAXOAG527EP7XV6RGB"
  secret_key = "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"
}