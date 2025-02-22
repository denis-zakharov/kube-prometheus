local ingress = import 'ingress.libsonnet';
local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/pyrra.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      alertmanager+: {
        replicas: 1,
      },
      prometheus+: {
        replicas: 1,
      },
      prometheusAdapter+: {
        replicas: 1,
      },
      // Configure Grafana External URL
      grafana+: {
        config+: {
          sections+: {
            server+: {
              root_url: 'http://grafana.minikube/',
            },
          },
        },
      },
    },

    // Configure External URL's per Prometheus application
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: 'http://alertmanager.minikube',
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: 'http://prometheus.minikube',
        },
      },
    },

    // Configure Ingress objects
    ingress+:: {
      alertmanager: ingress(
        name=$.alertmanager.alertmanager.metadata.name,
        namespace=$.values.common.namespace,
        rules=[{
          host: 'alertmanager.minikube',
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: $.alertmanager.service.metadata.name,
                  port: { name: 'web' },
                },
              },
            }],
          },
        }]
      ),
      prometheus: ingress(
        name=$.prometheus.prometheus.metadata.name,
        namespace=$.values.common.namespace,
        rules=[{
          host: 'prometheus.minikube',
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: $.prometheus.service.metadata.name,
                  port: { name: 'web' },
                },
              },
            }],
          },
        }]
      ),
      grafana: ingress(
        name=$.grafana.deployment.metadata.name,
        namespace=$.values.common.namespace,
        rules=[{
          host: 'grafana.minikube',
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: $.grafana.service.metadata.name,
                  port: { name: 'http' },
                },
              },
            }],
          },
        }]
      ),
    },
  };

{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
