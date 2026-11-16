#!/usr/bin/env python3
"""Read-only review of a Terraform plan before anyone runs apply.
Usage: terraform plan -out=tfplan && terraform show -json tfplan > plan.json
       tools/review-terraform-plan.py plan.json
Rules (FLAG exits 1; WARN is advice):
  FLAG  a stateful resource (database, bucket, volume, file system, key, cluster, table) is deleted or replaced
  FLAG  any resource is replaced and its type is not known to be safe to recreate (shown so a human decides)
  FLAG  a security group rule or network ACL change that opens 0.0.0.0/0 or ::/0
  FLAG  an IAM policy/role/user change that adds Action "*" with Resource "*" (administrator-style)
  WARN  any other delete; any IAM or security change; large plans (more than 50 changes)
It never runs terraform and never changes anything. Status: v0, tested on generated fixtures
(tools/test_review_terraform_plan.sh); not yet used on a real client plan. It reads the plan's
planned values only, so a module that hides an action behind a data source can still surprise you.
Exit: 0 no FLAG, 1 at least one FLAG, 2 usage or unreadable plan.
"""
import json, sys, re

STATEFUL = re.compile(r"^(aws_(db_instance|rds_cluster|rds_cluster_instance|s3_bucket|dynamodb_table|ebs_volume|efs_file_system|kms_key|eks_cluster|eks_node_group|elasticache_.*|opensearch_domain|elasticsearch_domain|secretsmanager_secret|ecr_repository|backup_vault|docdb_cluster|redshift_cluster|neptune_cluster|msk_cluster|kinesis_stream|sqs_queue|sns_topic)|google_(sql_database_instance|storage_bucket|bigquery_dataset|spanner_instance|kms_crypto_key)|azurerm_(mssql_database|mssql_server|postgresql.*|storage_account|key_vault|cosmosdb_account|kubernetes_cluster|managed_disk))$")
SECURITY = re.compile(r"^(aws_(iam_.*|security_group.*|vpc_security_group_.*|network_acl.*|s3_bucket_policy|kms_key_policy)|google_.*iam.*|azurerm_(role_assignment|network_security.*))$")
OPEN = re.compile(r'"?(0\.0\.0\.0/0|::/0)"?')

def after_text(change):
    return json.dumps(change.get("after") or {}, sort_keys=True)

def main(argv):
    if len(argv) != 1:
        print(__doc__); return 2
    try:
        plan = json.load(open(argv[0]))
    except (OSError, ValueError) as e:
        print(f"cannot read plan: {e}"); return 2
    changes = plan.get("resource_changes")
    if changes is None:
        print("not a terraform show -json plan (no resource_changes)"); return 2
    flags, warns, n = [], [], 0
    for rc in changes:
        acts = rc.get("change", {}).get("actions", [])
        if acts in (["no-op"], ["read"]) or not acts:
            continue
        n += 1
        addr, typ = rc.get("address", "?"), rc.get("type", "?")
        deleted = "delete" in acts
        replaced = deleted and "create" in acts
        if deleted and STATEFUL.match(typ):
            verb = "REPLACED (destroy and recreate)" if replaced else "DELETED"
            flags.append(f"{addr} ({typ}) will be {verb}; stateful data may be lost. Needs a restore point and explicit approval")
        elif replaced:
            flags.append(f"{addr} ({typ}) will be replaced; confirm recreation is safe (downtime, new IDs)")
        elif deleted:
            warns.append(f"{addr} ({typ}) will be deleted")
        text = after_text(rc.get("change", {}))
        if re.match(r"^aws_(security_group|vpc_security_group_ingress_rule|security_group_rule|network_acl.*)$", typ) and OPEN.search(text) and ("create" in acts or "update" in acts):
            flags.append(f"{addr} ({typ}) opens 0.0.0.0/0 or ::/0")
        if SECURITY.match(typ) and not deleted:
            warns.append(f"{addr} ({typ}) is an IAM or network security change; read the diff")
            if re.search(r'"Action"\s*:\s*(\[\s*)?"\*"', text.replace('\\"', '"')) and re.search(r'"Resource"\s*:\s*(\[\s*)?"\*"', text.replace('\\"', '"')):
                flags.append(f"{addr} ({typ}) grants Action * on Resource * (administrator-style)")
    if n > 50:
        warns.append(f"large plan: {n} resource changes; split it or review in parts")
    for x in flags: print("FLAG", x)
    for x in warns: print("WARN", x)
    print(f"review-terraform-plan: {n} change(s), {len(flags)} flag(s), {len(warns)} warning(s)")
    return 1 if flags else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
