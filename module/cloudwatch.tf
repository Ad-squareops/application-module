
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard"

  dashboard_body = <<EOF

{
   "start": "-PT9H",
   "periodOverride": "inherit",
   "widgets": [

       {
         "type": "metric",
                          "x": 0,
                          "y": 0,
                          "width": 9,
                          "height": 6,
                          "properties": {
                              "view": "bar",
                              "stacked": false,
                              "metrics": [
                                  [ "AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", "${module.asg.autoscaling_group_name}" ],
                                  [ ".", "GroupMaxSize", ".", "." ],
                                  [ ".", "GroupTotalCapacity", ".", "." ],
                                  [ ".", "GroupTotalInstances", ".", "." ],
                                  [ ".", "GroupInServiceInstances", ".", "." ]
                              ],
                              "region": "${var.region}",
                              "title": " ${module.asg.autoscaling_group_name}-stats"
         }
      },
      {
            "type": "explorer",
            "x": 0,
            "y": 6,
            "width": 24,
            "height": 15,
            "properties": {
                "metrics": [
                    {
                        "metricName": "CPUUtilization",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
	  	            {
                        "metricName": "mem_used_percent",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
	  	           {
                        "metricName": "cpu_usage_idle",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
		            {
                        "metricName": "cpu_usage_system",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
		            {
                        "metricName": "disk_used_percent",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "NetworkIn",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "NetworkOut",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    }
                ],
                	"aggregateBy": {
                    	"key": "InstanceId",
                    	"func": "AVG"
                },
                	"labels": [
                    {	
                        "key": "aws:autoscaling:groupName",
                        "value": "${module.asg.autoscaling_group_name}"
                    }
                ],
                	"widgetOptions": {
                    	"legend": {
                        "position": "bottom"
                    },
                    	"view": "timeSeries",
                    	"stacked": false,
                    	"rowsPerPage": 40,
                    	"widgetsPerRow": 3
                },
                	"period": 10,
                	"splitBy": "",
                	"title": "${module.asg.autoscaling_group_name}"
               }
        },
	    {
                 "type": "explorer",
                 "x": 0,
                 "y": 6,
                 "width": 24,
                 "height": 15,
                 "properties": {
                  "metrics": [
                    {
                        "metricName": "ActiveConnectionCount",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
                    {
                        "metricName": "ELBAuthError:",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
                    {
                        "metricName": "HTTP_Fixed_Response_Count",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
                    {
                        "metricName": "HTTPCode_ELB_3XX_Count",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
                    {
                        "metricName": "HTTPCode_ELB_4XX_Count",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
			{
                        "metricName": "HTTPCode_ELB_5XX_Count",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
			{
                        "metricName": "HTTPCode_ELB_502_Count",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
			{
                        "metricName": "HTTPCode_ELB_503_Count",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
			{
                        "metricName": "HTTPCode_ELB_504_Count",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
			{
                        "metricName": "RequestCount",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    },
			{
                        "metricName": "SurgeQueueLength",
                        "resourceType": "AWS::ElasticLoadBalancingV2::LoadBalancer/ApplicationELB",
                        "stat": "Average"
                    }

                ],
                	"aggregateBy": {
                    	"key": "Name",
                    	"func": "AVG"
                },
                	"labels": [
                    {	
                        "key": "Name",
                        "value": "${var.app_name}-alb"
                    }
                ],
                	"widgetOptions": {
                    	"legend": {
                        "position": "bottom"
                    },
                    	"view": "timeSeries",
                    	"stacked": false,
                    	"rowsPerPage": 40,
                    	"widgetsPerRow": 3
                },
                	"period": 10,
                	"splitBy": "",
                	"title": "${module.alb.lb_dns_name}"
	        }
        },

        {
                 "type": "explorer",
                 "x": 0,
                 "y": 6,
                 "width": 24,
                 "height": 15,
                 "properties": {
                  "metrics": [
                    {
                        "metricName": "UnhealthyHosts",
                        "resourceType": "AWS::ElasticLoadBalancingV2::TargetGroup",
                        "stat": "Maximum"
                    },
                    {
                        "metricName": "HealthyHosts:",
                        "resourceType": "AWS::ElasticLoadBalancingV2::TargetGroup",
                        "stat": "Average"
                    }

                ],
                	"labels": [
                    {	
                        "key": "Name",
                        "value": "${var.app_name}-TG"
                    }
                ],
                	"widgetOptions": {
                    	"legend": {
                        "position": "bottom"
                    },
                    	"view": "timeSeries",
                    	"stacked": false,
                    	"rowsPerPage": 2,
                    	"widgetsPerRow": 2
                },
                	"period": 10,
                	"splitBy": "",
                	"title": "${var.app_name}-TG"
	        }
       }
]
}
  
EOF
}
