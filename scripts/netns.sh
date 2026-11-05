#!/usr/bin/env bash
# WSL 用のネットワーク名前空間セットアップ (DHCP サーバーの検証環境)
# netns: LAN と隔離した DHCP 検証環境を、VM なしで用意するため
set -euo pipefail

NS_SRV=ns-server
IF_SRV=veth-server
NS_CLI=ns-client
IF_CLI=veth-client

SRV_ADDR=10.1.1.1/24

teardown() {
    ip netns del "$NS_SRV" 2>/dev/null || true
    ip netns del "$NS_CLI" 2>/dev/null || true
}

setup() {
    teardown
    ip netns add "$NS_SRV"
    ip netns add "$NS_CLI"

    ip link add "$IF_SRV" type veth peer name "$IF_CLI"
    ip link set "$IF_SRV" netns "$NS_SRV"
    ip link set "$IF_CLI" netns "$NS_CLI"

    # DHCP サーバーにのみ ip を割り振る
    ip -netns "$NS_SRV" addr add "$SRV_ADDR" dev "$IF_SRV"

    ip -netns "$NS_SRV" link set lo up
    ip -netns "$NS_SRV" link set "$IF_SRV" up
    ip -netns "$NS_CLI" link set lo up
    ip -netns "$NS_CLI" link set "$IF_CLI" up
}

case "${1:-}" in
    setup)    setup ;;
    teardown) teardown ;;
    *) echo "usage: sudo $0 {setup|teardown}" >&2; exit 1 ;;
esac
