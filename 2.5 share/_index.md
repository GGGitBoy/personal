

* 2.5 monitoring/alert/notifiers 操作部署流程变化 
    * 新添加的catalog相关crd
        * clusterrepo、app、operation
            * 添加了catalogv2，主要通过3个crd的协作来进行helm的部署操作
                * app：安装的应用程序是指通过我们的图表或通过Helm CLI安装的Helm 3图表
                * clusterrepo：仓库地址、分支设置
                * operation：helm操作，upgrade、uninstall等
        * 相较于之前v1，通过记录catalogtemplate，catalogtemplateversion的方式更加便捷一些
    * 新旧开启监控  （流程图）
        * 旧的方式部署监控
        * 新的方式部署监控
    * 新旧新建告警  （流程图）
        * 旧的方式创建告警
        * 新的方式创建告警

* 2.4与2.5的监控、告警功能区别分析
    * 添加、删除的东西  （分点）
        * 移除prometheus-auth
        * 移除系统告警（workload、pod、node、cis等）
        * notifier集成减少
        * 没有项目监控（权限验证）

        * 增加k8s-prometheus-adapter
        * 增加pushprox，针对controller-manager、etcd、kube-proxy、scheduler
    * 优劣势
        * 更加灵活、扩展性强，基于prometheus-operator

        * 使用过程需对prometheus-operator、helm等有一定了解
* promethues-operator的工作流程详解
    * crd介绍
    * prometheus、alertmanager介绍 （流程图）
        * alertmanager高可用
    * prometheus-operator版本变化
        * 禁用子目录
        * 添加pod mertrice
* Q&A 