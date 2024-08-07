### Observability services to include CloudWatch, Dashboards, CloudTrail, x-Ray, Alarms, eventbridge, Metrics, etc

resource "aws_cloudwatch_dashboard" "single_plane" {
  dashboard_name = "DASHBOARD_MASTER"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "Hello world"
        }
      }
    ]
  })
}