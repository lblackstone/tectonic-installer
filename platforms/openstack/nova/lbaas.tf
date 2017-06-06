resource "openstack_lb_loadbalancer_v2" "master_lb" {
  vip_subnet_id = "${var.tectonic_openstack_subnet_id}"
  name = "${var.tectonic_cluster_name}_master"
}

resource "openstack_lb_listener_v2" "master_lb_https_listener" {
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.master_lb.id}"
  protocol = "HTTPS"
  protocol_port = 443
}

resource "openstack_lb_pool_v2" "master_lb_pool" {
  lb_method = "ROUND_ROBIN"
  protocol = "HTTPS"
  listener_id = "${openstack_lb_listener_v2.master_lb_https_listener.id}"
}

resource "openstack_lb_member_v2" "master_lb_members" {
  count = "${var.tectonic_master_count}"
  address = "${openstack_compute_instance_v2.master_node.*.access_ip_v4[count.index]}"
  pool_id = "${openstack_lb_pool_v2.master_lb_pool.id}"
  protocol_port = 443
  subnet_id = "${var.tectonic_openstack_subnet_id}"
}

resource "openstack_lb_monitor_v2" "master_lb_monitor" {
  delay = 30
  max_retries = 3
  pool_id = "${openstack_lb_pool_v2.master_lb_pool.id}"
  timeout = 5
  type = "PING"
}
