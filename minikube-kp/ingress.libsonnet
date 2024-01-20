function(name, namespace, rules) {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: name,
    namespace: namespace,
  },
  spec: { rules: rules },
}
