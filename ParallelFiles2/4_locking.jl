using DataFrames

function f_bad()
    x = 0
    Threads.@threads for i in 1:10^7
        x += 1
    end
    return x
end

function f_atomic()
    x = Threads.Atomic{Int}(0)
    Threads.@threads for i in 1:10^7
        Threads.atomic_add!(x, 1)
    end
    return x[]
end

function f_spin()
    l = Threads.SpinLock()
    x = 0
    Threads.@threads for i in 1:10^7
        Threads.lock(l) do
            x += 1
        end
    end
    return x
end

function f_reentrant()
    l = ReentrantLock()
    x = 0
    Threads.@threads for i in 1:10^7
        Threads.lock(l) do
            x += 1
        end
    end
    return x
end

stats = DataFrame()
for f in [f_bad, f_atomic, f_spin, f_reentrant]
    for i = 1:2
        value, elapsedtime  = @timed f()
		push!(stats, (f=string(f),i=i, value=value, timems=elapsedtime*1000))
    end
end
println(stats)

