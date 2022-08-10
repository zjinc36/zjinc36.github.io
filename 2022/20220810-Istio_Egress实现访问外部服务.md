# Istio_Egress实现访问外部服务

----

## 访问外部服务的方法

+	配置`global.outboundTrafficPolicy.mode = ALLOW_ANY`
	*	不推荐,不太安全
	*	建议线上环境改成 `REGISTRY_ONLY`,只有注册的才能访问外部服务
+	使用服务入口(ServiceEntry)
	*	通过ServiceEntry将你的外部服务与它做一个映射,模拟成网格内部的服务
+	配置sidecar让流量绕过代理
	*	直接通过配置,让你跳过sidecar的管控,直接去访问外部服务
	*	不推荐,等于没用istio
+	配置Egress网关

## Egress概念

+	Egress网关:
	*	定义了网格的出口点，允许你将监控、路由等功能应用于离开网格的流量。
+	应用场景
	*	所有出口流量必须流经一组专用节点(安全因素)
	*	为无法访问公网的内部服务做代理


## 任务:创建Egress网关


![](../images/2022/08/20220810220726.png)

+	任务说明
	*	创建一个egress网关，让内部服务通过它访问外部服务
+	任务目标
	*	学会使用egress网关
	*	理解egress的存在意义



