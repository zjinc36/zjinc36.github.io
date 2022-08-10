# Istio_Ingress_控制进入网络的请求

---

+	服务的访问入口，接收外部请求并转发到后端服务
+	Istio 的Ingress gateway和Kubernetes Ingress的区别
	*	Kubernetes: 针对L7协议(资源受限) ，可定义路由规则
	*	Istio:针对L4-6协议，只定义接入点,复用Virtual Service的L7路由定义
		-	解耦了和路由规则的绑定:在这里只定义接入点,而把所有的路由规则全部交给Virtual Service
		-	复用:虚拟服务本身就可以重复利用

![](../images/2022/08/20220810155635.png)

## 任务:创建Ingress网关

+	任务说明
	*	为httpbin服务配置Ingress网关
+	任务目标
	*	理解Istio实现自己的Ingress的意义
	*	复习Gateway 的配置方法
	*	复习Virtual Service的配置方法

## 示例

1. 如果您启用了 Sidecar 自动注入，通过以下命令部署 httpbin 服务：

```bash
kubectl apply -f samples/httpbin/httpbin.yaml
```

2. 创建 Istio Gateway

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "httpbin.example.com"
```

3. 为通过 Gateway 的入口流量配置路由

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - "httpbin.example.com"	# 与Gateway对应,设置一个相同的hosts
  gateways:
  - httpbin-gateway			# 绑定刚才创建的Gateway的名称
  http:
  - match:					# 具体的路由信息配置
    - uri:
        prefix: /status
    - uri:
        prefix: /delay
    route:
    - destination:			# 目标地址指向了httpbin:8000这个服务
        port:
          number: 8000
        host: httpbin
```

4. 使用 curl 访问 httpbin 服务：

```bash
$ curl -s -I -HHost:httpbin.example.com "http://$INGRESS_HOST:$INGRESS_PORT/status/200"
HTTP/1.1 200 OK
server: istio-envoy
...
```

注意上文命令使用 `-H` 标识将 HTTP 头部参数 Host 设置为 `httpbin.example.com`。该操作为必须操作，因为 Ingress Gateway 已被配置用来处理 "httpbin.example.com" 的服务请求，而在测试环境中并没有为该主机绑定 DNS，而是简单直接地向 Ingress IP 发送请求。

# 参考

[Ingress Gateway](https://istio.io/latest/zh/docs/tasks/traffic-management/ingress/ingress-control/)

