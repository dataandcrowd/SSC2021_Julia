#!/bin/bash

julia -t 1 3_sum_thread.jl

julia -t 2 3_sum_thread.jl

julia -t 4 3_sum_thread.jl


