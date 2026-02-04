# CloudWatch Dashboard for EC2 Monitoring
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      # CPU Utilization
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average", id = "m1" }],
            ["HelloDevOps/EC2", "CPUUtilization", { stat = "Average", id = "m2" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "CPU Utilization"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        x      = 0
        y      = 0
        width  = 12
        height = 6
      },
      # Memory Utilization
      {
        type = "metric"
        properties = {
          metrics = [
            ["HelloDevOps/EC2", "MemoryUtilization", { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Memory Utilization"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        x      = 12
        y      = 0
        width  = 12
        height = 6
      },
      # Disk Utilization
      {
        type = "metric"
        properties = {
          metrics = [
            ["HelloDevOps/EC2", "DiskUtilization", { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Disk Utilization"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        x      = 0
        y      = 6
        width  = 12
        height = 6
      },
      # Network In/Out
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", { stat = "Sum", id = "m1" }],
            [".", "NetworkOut", { stat = "Sum", id = "m2" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Network Traffic"
          period  = 300
        }
        x      = 12
        y      = 6
        width  = 12
        height = 6
      },
      # Instance Status Check
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "StatusCheckFailed", { stat = "Maximum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Status Check Failed"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
        x      = 0
        y      = 12
        width  = 12
        height = 6
      },
      # Recent Logs
      {
        type = "log"
        properties = {
          query   = "SOURCE '/aws/ec2/${var.project_name}'\n| fields @timestamp, @message\n| sort @timestamp desc\n| limit 20"
          region  = var.aws_region
          title   = "Recent Logs"
        }
        x      = 12
        y      = 12
        width  = 12
        height = 6
      }
    ]
  })
}
