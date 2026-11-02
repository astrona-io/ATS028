---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Tracing A Service Request

The `shuttle` client cannot reach the `probe` Service. The failure might occur before name resolution, during backend selection, at a port or inside the application. Follow the request path rather than changing every network setting.

## Learning objectives

- Trace a request through name resolution, Service selection and backend listener.
- Distinguish selector, readiness and target-port faults.
- Choose a focused observation for each request boundary.

## Before you start

Use a shell on your own machine with the module playground running. A Pod is Kubernetes's unit for running one or more containers together. The environment provides the `probe` Deployment, which maintains application Pods, and the `starfleet` namespace, which groups these objects.

Read-only commands below use kubectl, the Kubernetes command-line tool. Select the private kubeconfig: the file that identifies this environment's cluster and credentials. The commands do not change the application.

## Tracing A Service Request

The `shuttle` client cannot reach `probe`. A request path includes name resolution, a Service access point, eligible endpoints, network forwarding and the application listener. Troubleshooting should distinguish these stages before changing unrelated workload settings.

If the name does not resolve, inspect the requested Service name, namespace search behavior and DNS reachability. A network policy that blocks DNS can look like a discovery failure. If the name resolves, record what it resolves to and continue testing the connection path conceptually rather than assuming the backend is healthy.

If the Service has no usable endpoints, inspect its selector and Pod readiness. If endpoints exist, check the client-facing port and backend target port. A ready Pod can still be paired with a Service that forwards to the wrong port. The relevant evidence is the application listener and configured mapping.

```mermaid
flowchart TB
    C["Client"] -->|"resolve name"| D["DNS"]
    C -->|"connect"| S["Service address"]
    S -->|"eligible endpoint"| P["Pod address"]
    P -->|"destination port"| A["Application listener"]
```
A successful stage narrows the investigation but does not prove the later stages are working.

Direct backend reachability with failed Service access can implicate selection, forwarding or port mapping. Failures from only one source can implicate that source's routing or egress policy. Failures after a connection succeeds may belong to application behavior, authentication or a downstream dependency.

Preserve the original symptom and verify from the affected client context after correcting a supported cause. Testing from an administrator's machine may use a different namespace, route or policy and therefore cannot establish that the original caller recovered.

## Tracing One Caller Through The Path

Assume `shuttle` in `outpost` uses the short Service name `probe`, but `probe` exists in `starfleet`. That lookup can fail or target another resource before any intended backend connection happens. A correct namespace-qualified name addresses discovery, not a missing listener or blocked network path.

Now assume the correct name resolves to a Service address. Inspect whether its selector finds the intended Pods and whether endpoints are eligible. A Running Pod failing readiness can be excluded from ordinary traffic. A selector with no match yields a different backend problem. Both occur after a successful DNS answer.

If a suitable endpoint exists, check the mapping from client port to destination port. Direct Pod access on the correct port may work while the Service targets another port. That evidence points toward mapping rather than a universal Pod-network failure. Source egress and destination ingress policies can also restrict the connection even with correct discovery and ports.

## Interpreting Transport And Application Results

A refused connection often indicates that the destination can be reached well enough to reject the attempt, but the expected listener is absent or rejecting it. A timeout supports a different set of possibilities, including dropped traffic or an unresponsive dependency. These are clues that need context, not perfect diagnoses by themselves.

An HTTP response moves the investigation further into application or intermediary behavior. Identify which component produced the response; a gateway can return an error without the request reaching the application. A successful TCP connection does not prove application authentication or database access works.

After correction, verify through the original caller's namespace, identity and route. A test from another source can bypass the policy or naming rule that caused the problem. The full request path matters because restoring one stage is useful only when the intended operation can traverse the remaining stages too.

## Inspect the mechanism

A Domain Name System (DNS) lookup turns the Service name into an address. Service routing then uses selected backend endpoints and the target port. A listener accepts the connection, after which the application interprets the request. Successful name resolution establishes only the first boundary.

The fixture exposes Service port 80 and targets the Pod's named `http` port, declared as 8080. A `containerPort` declaration documents this relationship; it does not create a listening process. The Python server must actually bind the expected address and port. Check the Service selector and ready endpoints before blaming the application handler for a connection that never reaches it.

```mermaid
flowchart TB
    C["Client request"] --> D["DNS resolution"]
    D --> S["Service address"]
    S --> E["Ready backend selection"]
    E --> L["Application listener"]
    L --> R["Application response"]
```

A request can fail at any boundary, and success at an earlier boundary does not prove the later ones.

<!-- astrona:playground:renew -->

Select the private cluster connection and inspect the live state from your host shell:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-050-02)"
if test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-050-02"; then
  kubectl -n starfleet get service probe -o yaml
  kubectl -n starfleet get pods -l app=probe -o wide
  kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o yaml
else
  printf "Select this module's private kubeconfig before continuing.\n" >&2
fi
```

Match the Service selector to Pod labels, then match endpoint addresses and ports to those Pods. Check endpoint readiness. This control-plane inspection sends no client request, so it cannot prove end-to-end reachability or resolve a DNS-specific symptom by itself. Use it to choose the precise next request observation.

You can now connect resource relationships to a request path and distinguish where evidence stops. A complete verification repeats the intended client operation after correcting the responsible boundary.

## Common pitfalls

> [!WARNING]
> Name resolution, endpoint selection, connection establishment and application responses are separate checks. Test the caller and path involved in the actual failure.
