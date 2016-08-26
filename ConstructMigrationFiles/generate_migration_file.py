import os
import sys
import subprocess

input_path        = "."

input_file   = "nigeria_by_state_gravity_squared_regional.txt"
output_prefix  = "Nigeria_by_state_gravity_squared"
route = "regional"

# write binary migration file from text input with lines like:
# Node1 index       Node2 index     rate
subprocess.call([sys.executable, "convert_txt_to_bin.py", input_file, os.path.join(input_path, output_prefix), route])
