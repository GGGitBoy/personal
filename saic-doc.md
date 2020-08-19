
## 一 准备工作

### 1.1 集群备份

#### 1.1.1 一级备份
集群升级后异常，满足回滚条件，可快速恢复。每个local集群节点均执行:   

`cp -r /var/lib/etcd /home/rke/etcd-bak-$(date +"%Y%m%d%H%M%S")`

#### 1.1.2 二级备份
通过rke再次对集群备份，用于一级备份失效后的集群恢复:   

`rke etcd snapshot-save --name SNAPSHOT-$(date +"%Y%m%d%H%M%S").db --config cluster.yml`

### 1.2 记录升级前的镜像版本
|  镜像   | 版本  |
|  ----  | ----  |
| rancher-server  | v2.3.8-ent-saic-1.0.2 |

## 二 升级步骤

### 2.1 镜像准备
|  镜像   | 版本  |
|  ----  | ----  |
| rancher-server  | dockerrrboy/rancher:refactor-monitoring |
| rancher-agent  | dockerrrboy/rancher-agent:refactor-monitoring |
| rancher-ui  | https://ly5156.xyz/saic-ui/2.3-fixes/index.html |

### 2.2 关闭所有项目监控

* 查看有开启项目监控的project，将项目监控disable

### 2.3 升级rancher server和rancher ui

#### 2.3.1 升级
* 进入local集群，修改`cattle-system`下的`rancher`， 编辑yaml，修改rancher的镜像为:    

    * rancher server: `dockerrrboy/rancher:refactor-monitoring`

* 进入setting，在ui-index处修改UI路径为:    

    * rancher UI: `https://ly5156.xyz/saic-ui/2.3-fixes/index.html`

#### 2.3.2 待升级完成
* 等待local集群rancher下的所有pod Running。

* 等待local集群和业务集群下的cluster-agent和node-agent 全部 Running。

### 2.4 修改仓库地址

* 进入catalogs，修改system-library为:    

    * catalog URL: `https://github.com/GGGitBoy/system-charts.git`
    * branch: `monitor-refactor-v0.1.7001`

### 2.5 升级监控

#### 2.5.1 升级

* 打开集群监控页面，选择监控版本0.0.7001，保存

#### 2.5.2 待升级完成

* 等待prometheus-cluster-monitoring和prometheus-operator-monitoring-operator等监控组件部署完成

## 三 功能验证

### 3.1 监控，告警功能验证

* 集群告警，项目告警功能正常
* 集群监控图表采集数据正常
* 集群和项目的自定义指标采集功能正常

### 3.2 监控多租户功能验证

* 不同用户只能查看自己拥有权限的资源数据

### 3.3 全局监控功能

* 全局监控Rancher UI图表显示正常
* 全局监控Grafana UI图表显示正常

### 3.4 Istio功能验证

* istio图表显示正常


## 四 设置告警表达式

### 4.1 告警表达式添加

* 添加告警组      
名称：A set of alerts for monitoring prometheus     
描述：Alert for prometheus     

* 添加告警     
1. 名称：High cardinality metrics     
表达式：`count by (__name__)({__name__=~".+"})`     
是：大于 10000      持续 5minutes     
发送：警告      

2. 名称：Prometheus config reload failed      
表达式：`prometheus_config_last_reload_successful{job="expose-prometheus-metrics",namespace="cattle-prometheus"}`     
是：等于 0      持续 10minutes     
发送：警告      

3. 名称：Prometheus notification queue running full      
表达式：`predict_linear(prometheus_notifications_queue_length{job="expose-prometheus-metrics",namespace="cattle-prometheus"}[5m], 60 * 30) > prometheus_notifications_queue_capacity{job="expose-prometheus-metrics",namespace="cattle-prometheus"}`      
是：不为空      持续 10minutes      
发送：警告     

4. 名称：Prometheus error sending alerts        
表达式：`rate(prometheus_notifications_errors_total{job="expose-prometheus-metrics",namespace="cattle-prometheus"}[5m]) / rate(prometheus_notifications_sent_total{job="expose-prometheus-metrics",namespace="cattle-prometheus"}[5m])`      
是：大于 0.03       持续 10minutes       
发送：危险     

5. 名称：Prometheus not ingesting samples        
表达式：`rate(prometheus_tsdb_head_samples_appended_total{job="expose-prometheus-metrics",namespace="cattle-prometheus"}[5m])`     
是：小于或等于 0        持续 10minutes       
发送：警告        

### 4.2 注意事项

高阶的表达式做查询的时候会比较占用prometheus的内存资源，因此如果有需要可以适当调整对prometheus的内存限制数值。避免prometheus因为OOM被杀掉，导致重启      

## 五 更新 CPU/Memory 告警表达式步骤
因监控版本升级到了0.0.7001，表达式中部分标签发生了变化，系统上升级前已配置的CPU/Memory使用率的告警表达式使用查询条件`name=~"^k8s_.*",image!=""`，其中的标签`name`,`image`已经不存在，需要更新升级前配置的项目级别CPU/Memory使用率的告警表达式。

### 5.1 步骤
* 配置环境变量，需要配置环境变量 `KUBECONFIG` 使运行脚本的环境能够访问到rancher server所在的集群
* 准备工具jq，[下载地址](https://github.com/stedolan/jq/releases) 
* 准备工具kubectl，[下载配置文档](https://kubernetes.io/zh/docs/tasks/tools/install-kubectl) 
* 运行脚本 update-project-alert-rule-expression.sh