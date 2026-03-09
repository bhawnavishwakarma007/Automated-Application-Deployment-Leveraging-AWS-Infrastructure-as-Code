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

## 🏗 Architecture Overview

    tf-user (access key in ~/.aws/credentials)
            ↓
        AssumeRole permission
            ↓
        tf-role (trusts tf-user)
            ↓
        Terraform

This is the correct and secure pattern for Terraform role-based authentication.

---

# ✅ Step 1 — Create IAM User (Programmatic Access)

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

# ✅ Step 2 — Create IAM Role

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

# ✅ Step 3 — Configure Trust Policy (VERY IMPORTANT)

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

# ✅ Step 4 — Give User Permission to Assume Role

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

# ✅ Step 5 — Configure AWS Credentials Locally

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

# ✅ Step 6 — Configure Terraform Provider

Create `provider.tf`:

    provider "aws" {
      region = "us-east-1"

      assume_role {
        role_arn     = "arn:aws:iam::875778602097:role/tf-role"
        session_name = "tf-session"
      }
    }

---

# ✅ Step 7 — Run Terraform

    terraform init
    terraform plan

Terraform will:

1. Authenticate using user access key  
2. Call STS AssumeRole  
3. Switch to tf-role  
4. Execute with role permissions  

---

# 🔎 Verify Terraform Is Using the Role

Add this data block:

    data "aws_caller_identity" "current" {}

Run:

    terraform apply

You should see:

    arn:aws:sts::875778602097:assumed-role/tf-role/...

That confirms Terraform is executing as the role.

---

# 🚨 Common Mistakes

❌ Using role ARN without credentials  
❌ Wrong trust policy  
❌ Using AIDA instead of full ARN  
❌ Not granting `sts:AssumeRole` to user  
❌ Not running `aws configure`  

---

# 🧠 Important Rule — Terraform Credential Order

Terraform checks credentials in this order:

1. Environment variables  
2. `~/.aws/credentials`  
3. EC2 instance metadata  

If none exist, you’ll get:

    No valid credential sources found

---

# ❓ Common Confusion: “Why Use IAM Role If We Still Need Access Keys?”

Many students ask:

“If we still run aws configure and provide access keys…  
then what is the point of using an IAM Role?”

This is an excellent and very important question.

---

# 🔐 Authentication vs Authorization (The Key Concept)

There are two different things happening:

1️⃣ Authentication → Who are you?  
2️⃣ Authorization → What are you allowed to do?  

In this setup:

| Component | Purpose |
|------------|----------|
| IAM User (access key) | Authentication |
| IAM Role | Authorization |

The IAM user proves identity.  
The IAM role defines permissions.

---

# 🔄 What Actually Happens

When Terraform runs:

1. It uses the IAM user's access key to authenticate with AWS.  
2. It calls `sts:AssumeRole`.  
3. AWS verifies:  
       - The role trusts the user  
       - The user has permission to assume the role  
4. AWS returns temporary credentials for the role.  
5. Terraform performs all actions using the role’s permissions — NOT the user’s.  

After step 2, the IAM user’s permissions are no longer used.

---

# 🔥 Why Not Just Give Permissions to the User?

You could attach `AdministratorAccess` directly to the IAM user.

But that is bad practice because:

❌ Long-lived credentials  
❌ Hard to rotate  
❌ Hard to separate environments  
❌ Higher security risk if leaked  
❌ Poor audit separation  

---

# ✅ Why IAM Role Is Better

Using a role provides:

✔ Temporary Credentials (they expire automatically)  
✔ Separation of Duties (User = identity, Role = permissions)  
✔ Environment Isolation  

You can create:

    dev-role
    staging-role
    prod-role

Same user → different roles.

✔ Production-Grade Pattern  

In real companies:

Very few IAM users  
Many IAM roles  

---

# 🧠 Important Clarification

The IAM user is only a bootstrap identity.

It exists only to:

- Authenticate  
- Call STS  
- Assume a role  

The IAM role is what actually executes infrastructure changes.

---

# 🚀 Real-World Analogy

Access key = Passport  
IAM Role = Work Visa  

You use your passport to obtain a visa.  
Then you work using the visa — not the passport.

---

# 🔐 Advanced Note (Production Systems)

In mature environments, IAM users are often removed entirely.

Instead, teams use:

- EC2 Instance Roles  
- GitHub OIDC → AssumeRole  
- AWS SSO  
- IRSA (EKS)  

In those setups:

No long-lived access keys are stored locally.  
Everything uses temporary credentials.

---

# ✅ Final Understanding

We still configure access keys because Terraform needs an initial identity.

But we use IAM Roles because:

Authentication should be separate from Authorization.

That separation is what makes this architecture secure, scalable, and production-ready.
