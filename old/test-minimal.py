#!/usr/bin/env python3
import argparse

parser = argparse.ArgumentParser(description='Test')
parser.add_argument('--foo', help='Foo option')
args = parser.parse_args()

print("Script finished")
