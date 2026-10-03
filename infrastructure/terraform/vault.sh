# 1. Enable the Key/Value secret engine
vault secrets enable -path=secret kv-v2

# 2. Store a mock MongoDB URI for the Wallet Service
vault kv put secret/finedge/wallet mongodb_uri="mongodb://admin:VaultInjectedPassword123@mongodb:27017"

# 3. Enable Kubernetes Authentication
vault auth enable kubernetes

# 4. Tell Vault how to securely communicate with the k3s API
vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

# 5. Create a security policy that only allows reading the wallet secret
vault policy write wallet-policy - <<POLICY
path "secret/data/finedge/wallet" {
  capabilities = ["read"]
}
POLICY

# 6. Bind that policy to a specific Kubernetes ServiceAccount (wallet-sa)
vault write auth/kubernetes/role/wallet-role \
    bound_service_account_names=wallet-sa \
    bound_service_account_namespaces=default \
    policies=wallet-policy \
    ttl=1h