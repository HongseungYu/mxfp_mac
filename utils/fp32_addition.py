import struct

def hex_to_float(hex_str):
    """Convert a hex string to a float."""
    int_bits = int(hex_str, 16)
    float_val = struct.unpack('!f', int_bits.to_bytes(4, byteorder='big'))[0]
    return float_val

def float_to_hex(f):
    """Convert a float to a hex string."""
    [int_bits] = struct.unpack('!I', struct.pack('!f', f))
    return format(int_bits, '08x')

def fp32_addition(hex1, hex2):
    """Add two 32-bit IEEE 754 floating point numbers represented as hex strings."""
    # Convert hex to float
    float1 = hex_to_float(hex1)
    float2 = hex_to_float(hex2)

    # Perform addition
    result = float1 + float2

    # Convert result back to hex
    result_hex = float_to_hex(result)
    return result_hex

# Example usage
hex1 = "c42bad56"
hex2 = "477da000"
result = fp32_addition(hex1, hex2)
print("Result:", result)
