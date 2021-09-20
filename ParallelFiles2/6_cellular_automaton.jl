using Distributed
@everywhere using ParallelDataTransfer, Distributed


@everywhere function rule30()
    lastv = Main.caa[1]
    for i in 2:(length(Main.caa)-1)
        current = Main.caa[i]
        Main.caa[i] = xor(lastv, Main.caa[i] || Main.caa[i+1])
        lastv = current
    end
end


@everywhere function getcaa()
    Main.caa
end
@everywhere function getsetborder()
    #println(myid(),"gs");flush(stdout)
    Main.caa[1] = (@fetchfrom Main.neighbours[1] getcaa()[15+1])
	#println(myid(),"gs1");flush(stdout)
    Main.caa[end] = (@fetchfrom Main.neighbours[2] getcaa()[2])
	#println(myid(),"gse");flush(stdout)
end

function printsimdist(workers::Array{Int})
    for w in workers
        dat = @fetchfrom w caa
        for b in dat[2:end-1]
            print(b ? "#" : " ")
        end
    end
    println()
end

function runca(steps::Int, visualize::Bool)
    @sync for w in workers()
        @async @fetchfrom w fill!(caa, false)
    end
    @fetchfrom wks[Int(nwks/2)+1] caa[2]=true
    visualize && printsimdist(workers())
    for i in 1:steps
        @sync for w in workers()
            @async @fetchfrom w getsetborder()
        end
        @sync for w in workers()
            @async @fetchfrom w rule30()
        end
        visualize && printsimdist(workers())
    end
end

wks = workers()
nwks = length(wks)
for i in 1:nwks
    sendto(wks[i], neighbours = (i==1 ? wks[nwks] : wks[i-1],
                                i==nwks ? wks[1] : wks[i+1]))
    fetch(@defineat wks[i] const caa = zeros(Bool, 15+2));
end

runca(20,true)
