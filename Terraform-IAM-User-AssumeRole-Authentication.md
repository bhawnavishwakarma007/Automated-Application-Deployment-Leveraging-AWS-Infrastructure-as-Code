# Terraform Authentication via IAM User → AssumeRole → IAM Role

---

## 🎯 Goal

Authenticate Terraform using the following secure flow:

    IAM User (access key)
            ↓
        AssumeRole
            ↓
        IAM Role
            ↓
        Terraform

> ❗ You **cannot authenticate using only a role ARN**.  
> You **must start with an IAM user or AWS SSO session**.

---

## ✅ Step 1 — Create IAM User (Programmatic Access)

Navigate to:

    IAM → Users → Create user

**Name:**

    tf-user

After creation:

    👉 Go to Security credentials  
    👉 Create Access Key  
    👉 Copy:

    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY

⚠️ **Save them securely. You won’t see the secret again.**

---

## ✅ Step 2 — Create IAM Role

Navigate to:

    IAM → Roles → Create role

Select:

    AWS account

Attach policy:

    AdministratorAccess

(or any scoped policy you actually need)

**Name:**

    tf-role

---

## ✅ Step 3 — Configure Trust Policy (VERY IMPORTANT)

Navigate to:

    IAM → Roles → tf-role → Trust relationships → Edit trust policy

Replace with:

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::875778602097:user/tf-user"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }

✔ Save

This allows **tf-user** to assume **tf-role**.

---

## ✅ Step 4 — Give User Permission to Assume Role

Navigate to:

    IAM → Users → tf-user → Add permissions → Create inline policy

Paste:

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Resource": "arn:aws:iam::875778602097:role/tf-role"
        }
      ]
    }

✔ Save

Now:

- ✅ The role **trusts** the user  
- ✅ The user has permission to **assume the role**

Both sides must match.

---

## ✅ Step 5 — Configure AWS Credentials Locally

Run:

    aws configure

Enter:

    Access Key ID:     (paste key)
    Secret Access Key: (paste secret)
    Region:            us-east-1
    Output:            json

Test authentication:

    aws sts get-caller-identity

You should see:

    arn:aws:iam::875778602097:user/tf-user

If this works → your base authentication is correct.

---

## ✅ Step 6 — Configure Terraform Provider

Create `provider.tf`:

    provider "aws" {
      region = "us-east-1"

      assume_role {
        role_arn     = "arn:aws:iam::875778602097:role/tf-role"
        session_name = "tf-session"
      }
    }

---

## ✅ Step 7 — Run Terraform

    terraform init
    terraform plan

Terraform will:

1. Authenticate using user access key  
2. Call STS AssumeRole  
3. Switch to tf-role  
4. Execute with role permissions  

---

## 🔎 Verify Terraform Is Using the Role

Add this data block:

    data "aws_caller_identity" "current" {}

Run:

    terraform apply

You should see:

    arn:aws:sts::875778602097:assumed-role/tf-role/...

That confirms Terraform is executing as the role.

---

## 🚨 Common Mistakes

❌ Using role ARN without credentials  
❌ Wrong trust policy  
❌ Using AIDA instead of full ARN  
❌ Not granting `sts:AssumeRole` to user  
❌ Not running `aws configure`  

---

## 🧠 Important Rule — Terraform Credential Order

Terraform checks credentials in this order:

1. Environment variables  
2. `~/.aws/credentials`  
3. EC2 instance metadata  

If none exist, you’ll get:

    No valid credential sources found

---

## 🔥 Final Working Architecture

    tf-user (access key in ~/.aws/credentials)
            ↓
        AssumeRole permission
            ↓
        tf-role (trusts tf-user)
            ↓
        Terraform

---

✔ This is the correct and secure pattern for Terraform role-based authentication.
