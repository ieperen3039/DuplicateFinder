const std = @import("std");
const ArrayList = std.ArrayList;

const Duplicate = struct { first_index : usize, second_index : usize };

const MyReadLine = struct {
    bytes : []u8,
    num_chars_read : usize,
};

fn nextLine(reader: std.io.AnyReader, buffer: []u8) !?MyReadLine {
    const line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;

    return MyReadLine{
        .bytes = std.mem.trimRight(u8, line, "\r\n"),
        .num_chars_read = line.len
    };
}

const Hash = u128;

const LineCache = struct {
    start_char : usize,
    hash : Hash,
};

fn makeHash(buffer: []Hash) u128 {
    var hash : Hash = 0x0000_0000_0000_0000;
    for (0..buffer.len) |i| {
        // rotating bit shift (not in the language yet)
        hash = (hash << 7) | (hash >> (@sizeOf(Hash) - 7));
        hash ^= buffer[i];
    }
    return hash;
}

pub fn findDuplicates(reader: std.io.AnyReader) ArrayList(Duplicate)
{
    var line_cache = ArrayList(LineCache){};
    var current_char = 0;
    
    const read_buffer_size = 1024;
    var buffer = union {
        read_buffer : [read_buffer_size]u8,
        hash_buffer : [read_buffer_size / @sizeOf(Hash)]Hash,
    }{};

    while (try nextLine(reader, &buffer.read_buffer)) |line| {
        const start_char = current_char;
        current_char += line.num_chars_read;

        const hash_block_size = @sizeOf(Hash);
        const hash_iteration_count = line.bytes.len / hash_block_size;
        const remainder = line.bytes.len % hash_block_size;
        const block_end = (hash_iteration_count + 1) * hash_block_size;

        for (remainder..block_end) |i| {
            buffer.read_buffer[i] = 0x00;
        }

        const hash = makeHash(&buffer.hash_buffer[0..hash_iteration_count]);

        line_cache.append(LineCache{.start_char = start_char, .hash = hash});
    }
}