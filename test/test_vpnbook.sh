#!/bin/sh
. ../vpnbook

if [ -z "$SHUNIT" ]; then
	SHUNIT="./shunit2-2.1.6/src/shunit2"
fi

get_test_data() {
	cat "./testdata/freevpn.html"
}

test_extract_credentials() {
	local result="$(get_test_data | extract_credentials)"
	local expected="$(cat <<-EOF
		vpnbook
		qe5Egawr
		EOF
	)"
	assertEquals "$expected" "$result"

	echo "Wrong input" | extract_credentials
	assertEquals 1 $?
}

test_extract_config_urls() {
	local result="$(get_test_data | extract_config_urls)"
	local expected="$(cat <<-EOF
	http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro1.zip
	http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro2.zip
	http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-UK1.zip
	http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-US1.zip
	EOF
	)"
	assertEquals "$expected" "$result"
}

test_generate_vpn_config() {
	local expected="$(cat ./testdata/output.ovpn)"
	local result="$(cat ./testdata/vpnbook-euro1-udp53.ovpn | generate_vpn_config)"

	assertEquals "$expected" "$result"
}

test_generate_auth() {
	AUTH_FILE="${SHUNIT_TMPDIR}/a"
	generate_auth "$(get_test_data)"
	assertTrue $?
	assertTrue "[ -f $AUTH_FILE ]"
	assertEquals "100600" "$(stat -f '%p' $AUTH_FILE)"
}

. "$SHUNIT"
