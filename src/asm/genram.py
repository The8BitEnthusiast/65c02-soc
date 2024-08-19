output = [0] * 16384

with open('ram.bin', 'wb') as file:
    for x in output:
        file.write(x.to_bytes(1, byteorder = 'big', signed=False))
        
