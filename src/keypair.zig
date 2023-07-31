const std = @import("std");
const debug = std.debug;
const fs = std.fs;
const mem = std.mem;
const os = std.os;
const testing = std.testing;

pub const KeyPair = struct {
    public: [32]u8,
    private: [32]u8,

    pub fn publicBase64(self: KeyPair) [44]u8 {
        var buffer: [44]u8 = undefined;
        _ = std.base64.standard.Encoder.encode(&buffer, &self.public);
        return buffer;
    }

    pub fn privateBase64(self: KeyPair) [44]u8 {
        var buffer: [44]u8 = undefined;
        _ = std.base64.standard.Encoder.encode(&buffer, &self.private);
        return buffer;
    }
};

pub fn generateKeyPair() !KeyPair {
    var privkey = std.crypto.ecc.Curve25519.scalar.random();
    std.crypto.ecc.Curve25519.scalar.clamp(&privkey);
    const pubkey = blk: {
        const curve = try std.crypto.ecc.Curve25519.basePoint.clampedMul(privkey);
        break :blk curve.toBytes();
    };
    return KeyPair{
        .public = pubkey,
        .private = privkey,
    };
}

pub fn fromPrivateKey(privkey: [32]u8) !KeyPair {
    const pubkey = blk: {
        const curve = try std.crypto.ecc.Curve25519.basePoint.clampedMul(privkey);
        break :blk curve.toBytes();
    };
    return KeyPair{
        .public = pubkey,
        .private = privkey,
    };
}

test "key length" {
    try testing.expectEqual(@as(usize, 44), std.base64.url_safe.Encoder.calcSize(32));
}