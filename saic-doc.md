
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
| rancher-server  | dockerrrboy/rancher:dev |
| rancher-agent  | dockerrrboy/rancher-agent:dev |
| rancher-ui  | https://wj-pandaria-ui.s3-ap-northeast-1.amazonaws.com/static/2.3-dev/index.html | 
 
### 2.2 关闭所有项目监控

* 查看有开启项目监控的project，将项目监控disable

### 2.3 升级rancher server和rancher ui

#### 2.3.1 升级
* 进入local集群，修改`cattle-system`下的`rancher`， 编辑yaml，修改rancher的镜像为:    

rancher server: `dockerrrboy/rancher:dev`

* 进入setting，在ui-index处修改UI路径为:    

rancher UI: `https://wj-pandaria-ui.s3-ap-northeast-1.amazonaws.com/static/2.3-dev/index.html`

#### 2.3.2 待升级完成
* 等待local集群rancher下的所有pod Running。

* 等待local集群和业务集群下的cluster-agent和node-agent 全部 Running。

### 2.4 修改仓库地址

* 进入catalogs，修改system-library为:    

catalog URL: `https://github.com/GGGitBoy/system-charts.git`
branch: `monitor-refactor-v0.1.7001`
 
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


