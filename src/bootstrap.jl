include("KissThreading.jl")

using KissThreading

src = [rand(400) for i in 1:100]
dst = similar(src, Float64)

println("running with $(Threads.nthreads()) thread(s)")
tic()
tmap!(src, dst) do x
    rng = TRNG[Threads.threadid()]
    std([mean(rand(rng, x, length(x))) for i in 1:20000])
end
toc()
@assert all(round.(std.(src)./dst/20, 1) .== 1.0)

function simple(src, dst)
    rngs = randjump(Base.GLOBAL_RNG, Threads.nthreads())
    @Threads.threads for k in 1:length(src)
        x = src[k]
        rng = rngs[Threads.threadid()]
        dst[k] = std([mean(rand(rng, x, length(x))) for i in 1:20000])
    end
end

tic()
simple(src, dst)
toc()
@assert all(round.(std.(src)./dst/20, 1) .== 1.0)

