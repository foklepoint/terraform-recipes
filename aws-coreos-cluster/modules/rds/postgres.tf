resource "aws_db_subnet_group" "coreos_cluster" {
    name = "coreos-cluster-db"
    description = "db subnets for coreos-cluster applications"
    subnet_ids = ["${var.rds_subnet_a_id}","${var.rds_subnet_b_id}","${var.rds_subnet_c_id}"]
}

resource "aws_db_instance" "coreos_cluster" {

    identifier = "coreos-cluster"
    allocated_storage = 10
    engine = "postgres"
    engine_version = "9.3.5"
    instance_class = "db.t1.micro"
    storage_type = "gp2"
    name = "dockerage"
    username = "${var.db_user}"
    password = "${var.db_password}"
    multi_az = "false" 
    availability_zone = "${var.rds_subnet_az_b}"
    port = "5432"
    publicly_accessible = "false"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    backup_window = "09:19-10:19"
    vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
    db_subnet_group_name = "${aws_db_subnet_group.coreos_cluster.id}"
}

/* bug - tfp wanted to re-created the record.
resource "aws_route53_record" "star_postgresdb" {
    zone_id = "${var.route53_private_zone_id}"
    name = "*.postgresdb"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.coreos_cluster.address}" ]
}
*/
