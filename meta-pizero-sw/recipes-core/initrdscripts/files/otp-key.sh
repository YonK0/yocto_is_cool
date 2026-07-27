#!/bin/sh
# otp-key.sh -- derive LUKS keys from the per-device customer OTP secret.
# Sourced by the initramfs /init (boot.sh):   . /otp-key.sh ; k=$(derive_key data)
# Self-check:                                  sh otp-key.sh --selftest

OTP_ROWS=8                      # 8 x 32-bit customer rows = 256-bit secret
OTP_TAG_GET=0x00030021          # RPi mailbox property tag: GET_CUSTOMER_OTP
VCIO=/dev/vcio

_kdf() {                        # _kdf <secret_hex> <label> -> 64 hex chars
    printf '%s%s' "$1" "$2" | sha256sum | cut -d' ' -f1
}

read_otp_secret() {             # -> 64 hex on stdout, or non-zero (fail closed)
    if [ -e "$VCIO" ]; then
        # vcmailbox <tag> <rbuf_bytes> <req_bytes> <start_row> <num_rows>; the
        # row values are the last OTP_ROWS 0x-words of the response.
        hex=$(vcmailbox "$OTP_TAG_GET" $(( (2 + OTP_ROWS) * 4 )) 8 0 "$OTP_ROWS" 2>/dev/null \
              | tr ' ' '\n' | grep -i '^0x' | tail -n "$OTP_ROWS" \
              | sed 's/^0[xX]//' | tr 'A-Z' 'a-z' | tr -d '\n')
    else
        echo "otp-key: no $VCIO !!" >&2
    fi

    case "$hex" in
        "" | *[!0-9a-f]*) echo "otp-key: OTP unreadable -- fail closed" >&2; return 1 ;;
    esac
    [ "${#hex}" -eq 64 ] || { echo "otp-key: bad OTP length ${#hex}" >&2; return 1; }
    case "$hex" in
        0000000000000000000000000000000000000000000000000000000000000000 \
        | ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            echo "otp-key: customer OTP unprogrammed -- fail closed" >&2; return 1 ;;
    esac
    printf '%s' "$hex"
}

derive_key() {                  # <label> -> 64 hex; reads OTP once, then caches
    [ -n "$1" ] || return 1
    [ -n "${_OTP_SECRET:-}" ] || _OTP_SECRET=$(read_otp_secret) || return 1
    _kdf "$_OTP_SECRET" "$1"
}

# --- self-check: assert the KDF invariants (no OTP/hardware needed) ----------
if [ "${1:-}" = "--selftest" ]; then
    s=00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff
    a=$(_kdf "$s" data); b=$(_kdf "$s" rootfs); a2=$(_kdf "$s" data)
    [ "${#a}" -eq 64 ] || { echo "FAIL: key is not 64 hex chars"; exit 1; }
    [ "$a" != "$b" ]   || { echo "FAIL: different labels share a key"; exit 1; }
    [ "$a" = "$a2" ]   || { echo "FAIL: derivation is not deterministic"; exit 1; }
    echo "otp-key selftest OK"
fi
