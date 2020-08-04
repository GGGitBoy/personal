## 从监控 v1 迁移 到 v2

### 迁移前需知

监控 v1 迁移到 v2 之后有些功能暂不支持

1. 多租户查询、告警配置【只能通过rbac去规范角色对资源的权限】
2. 告警接收者选择钉钉、MS teams【单独部署webhook-reveiver实现】
3. 事件等额外的告警【大部分可改为对应的表达式告警】

### 开始迁移

**旧数据准备**

* grafana 仪表盘

找到想要导出到 v2 的仪表盘，将其对应的json模型以文件形式导出，替换所有 “datasource”:“RANCHER_MONITORING” 为 “datasource”:“Prometheus”

<img width="1260" alt="截屏2021-04-01 下午2 50 57" src="https://user-images.githubusercontent.com/51182588/113263112-f5071880-9303-11eb-9399-0b6f8e9774a4.png">

* prometheus、alertmanager

将 prometheus、alertmanager 的yaml文件导出供后面开启 v2 监控参考

* serviceMonitor、prometheusRule

使用辅助迁移脚本 monitoring-resource-output.sh 将 serviceMonitor、prometheusRule 对应内容导出替换

<img width="696" alt="截屏2021-04-02 下午1 28 45" src="https://user-images.githubusercontent.com/51182588/113384029-bfbc0280-93b7-11eb-818c-60de571803ed.png">

* notifier 内容

记录当前有被使用的 notifier 参数配置

**清理 v1 监控**

* 删除所有配置了接收者的告警、告警组

* 删除所有不需要的 notifier

* 禁用 v1 监控

* 确保 应用商店 的所有告警、监控相关app都已移除

<img width="1202" alt="截屏2021-04-01 下午3 07 05" src="https://user-images.githubusercontent.com/51182588/113263231-1962f500-9304-11eb-8210-29688847c49e.png">

**部署 v2 监控**

* 根据之前导出 prometheus、alertmanager 的yaml参数开启 v2 监控

* 确保监控相关工作负载状态为active

<img width="1356" alt="截屏2021-04-01 下午3 11 22" src="https://user-images.githubusercontent.com/51182588/113263265-208a0300-9304-11eb-9228-6d95ee97e116.png">

**添加旧数据** 

* 导入grafana仪表盘

在命名空间 cattle-dashboards 创建一个 ConfigMap，添加标签 grafana_dashboard: "1"，并将之前准备的 grafana json模型导入

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-dashboard
  namespace: cattle-dashboards
  labels:
    grafana_dashboard: "1"
data:
  custom-dashboard.json: |
    { 
      ... 
    }
```

* serviceMonitor、prometheusRule

使用辅助迁移脚本 monitoring-resource-apply.sh 将相关的资源进行部署

<img width="798" alt="截屏2021-04-02 下午1 29 56" src="https://user-images.githubusercontent.com/51182588/113384054-cd718800-93b7-11eb-9efe-9d7164a9aa79.png">

* 根据导出 notifier 参数配置，在 receiver、routes 处添加告警对应的接收者

<img width="1404" alt="截屏2021-04-01 下午3 11 52" src="https://user-images.githubusercontent.com/51182588/113263289-28e23e00-9304-11eb-8dc3-15bd43abc42c.png">

## 从日志 v1 迁移 到 v2

### 迁移前需知

日志 v1 迁移到 v2 之后有些功能暂不支持

1. 从pod内文件读取
2. 项目日志收集【使用namespace收集替代】
3. 输出组件syslog

### 开始迁移

**记录输出插件**

v2 日志使用的是 logging-operator 来部署相关的组件，在关闭 v1 日志前我们只需记录好输出插件的相应配置即可

**禁用 v1 日志**

确保 应用商店 的 fluentd app 已移除

**启用 v2 日志**

等待所有组件状态为active

<img width="1331" alt="截屏2021-04-01 下午3 38 06" src="https://user-images.githubusercontent.com/51182588/113263314-2ed81f00-9304-11eb-89bd-581aa1dfac2e.png">

**logging-operator 对应 crd 配置**

集群日志收集配置 ClusterFlow 输出到 ClustrOutput
项目日志收集通过不同命名空间的 Flow 组合输出到 ClustrOutput 或 Output