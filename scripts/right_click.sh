#!/bin/bash
# Simulate a right-click using wtype
wtype --keydown Control_L  # Hold down the left Control key (optional)
wtype --key 135            # Send the Menu Key (keycode for right-click)
wtype --keyup Control_L    # Release the left Control key (optional)
