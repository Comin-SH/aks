# resource_group_location = "value"
# resource_group_name = "value"
# agent_pool_node_count = 0
# agent_pool-vm_size = "value"
# user_pool-vm_size = "value"
# user_pool_node_count = 0
# cluster_name = "value"
# dns_prefix = "value"
subscription_id = "9eb1d0a1-210a-4b35-a46f-fc86076e242e"

# Freigelassen aus Testgründen, da diese Berechtigungen aus irgendeinem Grund nicht im Azure Portal sichtbar sind
#admin_group_object_ids = []
rbac_reader_group_object_ids = []
rbac_admin_group_object_ids = ["7e9fe796-1a3b-4d2e-b2fe-b0cb0f3f5c49"]

STORAGE_ACCOUNT_NAME = "lokistorageacct01"

workload_identity_name = "workload-identity-loki"
keyvault_name = "cikeyvaulttest"
SECRET_GRAFANA_ADMIN_PASSWORD = "EinStarkesPasswort123!"