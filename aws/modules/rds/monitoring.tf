variable "alert_topic_arn" {
  type = string
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "${var.instance_name}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors CPU utilization for RDS instance ${var.instance_name}"
  alarm_actions       = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]
  ok_actions          = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]


  dimensions = {
    DBInstanceIdentifier = var.instance_name
  }

  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "freeable_memory_alarm" {
  alarm_name          = "${var.instance_name}-freeable-memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = 1000 * 1000 * 100 # 100 mb
  alarm_description   = "This metric monitors memory utilization for RDS instance ${var.instance_name}"
  alarm_actions       = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]
  ok_actions          = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]


  dimensions = {
    DBInstanceIdentifier = var.instance_name
  }

  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "free_storage" {
  alarm_name          = "${var.instance_name}-free-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = 1000 * 1000 * 1000 * 2 # 2gb
  alarm_description   = "This metric monitors storage utilization for RDS instance ${var.instance_name}"
  alarm_actions       = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]
  ok_actions          = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]


  dimensions = {
    DBInstanceIdentifier = var.instance_name
  }

  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  alarm_name          = "${var.instance_name}-disk-queue-depth"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "This metric monitors disk queue depth for RDS instance ${var.instance_name}"
  alarm_actions       = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]
  ok_actions          = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]


  dimensions = {
    DBInstanceIdentifier = var.instance_name
  }

  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "disk_read_iops" {
  alarm_name          = "${var.instance_name}-disk-read-iops"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "500"
  alarm_description   = "This metric monitors READ IOPS for RDS instance ${var.instance_name}"
  alarm_actions       = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]
  ok_actions          = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]


  dimensions = {
    DBInstanceIdentifier = var.instance_name
  }

  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "disk_write_iops" {
  alarm_name          = "${var.instance_name}-disk-write-iops"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "500"
  alarm_description   = "This metric monitors WRITE IOPS for RDS instance ${var.instance_name}"
  alarm_actions       = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]
  ok_actions          = var.alert_topic_arn == "" ? [] : [var.alert_topic_arn]

  dimensions = {
    DBInstanceIdentifier = var.instance_name
  }

  insufficient_data_actions = []
}

