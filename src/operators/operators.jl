module Operators

export
    δx!,
    δy!,
    δz!,
    avgx!,
    avgy!,
    avgz!,
    div!,
    div_flux!,
    u∇u!,
    u∇v!,
    u∇w!,
    κ∇²!,
    𝜈∇²u!,
    𝜈∇²v!,
    𝜈∇²w!

include("ops_regular_cartesian_grid.jl")

end
