#!/bin/bash
# ============================================
# Connect k8s-bgp-speaker to kind network
# Run once after cluster creation
# ============================================
echo "Connecting k8s-bgp-speaker to kind network..."
docker network connect kind k8s-bgp-speaker 2>/dev/null || echo "(already connected)"
docker inspect k8s-bgp-speaker \
  --format 'Networks: {{range $k,$v := .NetworkSettings.Networks}}{{$k}}={{$v.IPAddress}} {{end}}'
echo "Done!"
