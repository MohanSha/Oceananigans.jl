using Oceananigans:
    RegularCartesianGrid,
    CellField, FaceField, FaceFieldX, FaceFieldY, FaceFieldZ

# Increment and decrement integer a with periodic wrapping. So if n == 10 then
# incmod1(11, n) = 1 and decmod1(0, n) = 10.
@inline incmod1(a, n) = a == n ? one(a) : a + 1
@inline decmod1(a, n) = a == 1 ? n : a - 1

"""
    δx!(g::RegularCartesianGrid, f::CellField, δxf::FaceField)

Compute the difference \$\\delta_x(f) = f_E - f_W\$ between the eastern and
western cells of a cell-centered field `f` and store it in a face-centered
field `δxf`, assuming both fields are defined on a regular Cartesian grid `g`
with periodic boundary condition in the \$x\$-direction.
"""
function δx!(g::RegularCartesianGrid, f::CellField, δxf::FaceField)
    for k in 1:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds δxf.data[i, j, k] =  f.data[i, j, k] - f.data[decmod1(i, g.Nx), j, k]
    end
    nothing
end

"""
    δx!(g::RegularCartesianGrid, f::FaceField, δxf::CellField)

Compute the difference \$\\delta_x(f) = f_E - f_W\$ between the eastern and
western faces of a face-centered field `f` and store it in a cell-centered
field `δxf`, assuming both fields are defined on a regular Cartesian grid `g`
with periodic boundary conditions in the \$x\$-direction.
"""
function δx!(g::RegularCartesianGrid, f::FaceField, δxf::CellField)
    for k in 1:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds δxf.data[i, j, k] =  f.data[incmod1(i, g.Nx), j, k] - f.data[i, j, k]
    end
    nothing
end

"""
    δy!(g::RegularCartesianGrid, f::CellField, δyf::FaceField)

Compute the difference \$\\delta_y(f) = f_N - f_S\$ between the northern and
southern cells of a cell-centered field `f` and store it in a face-centered
field `δyf`, assuming both fields are defined on a regular Cartesian grid `g`
with periodic boundary condition in the \$y\$-direction.
"""
function δy!(g::RegularCartesianGrid, f::CellField, δyf::FaceField)
    for k in 1:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds δyf.data[i, j, k] =  f.data[i, j, k] - f.data[i, decmod1(j, g.Ny), k]
    end
    nothing
end

"""
    δy!(g::RegularCartesianGrid, f::FaceField, δyf::CellField)

Compute the difference \$\\delta_y(f) = f_N - f_S\$ between the northern and
southern faces of a face-centered field `f` and store it in a cell-centered
field `δyf`, assuming both fields are defined on a regular Cartesian grid `g`
with periodic boundary condition in the \$y\$-direction.
"""
function δy!(g::RegularCartesianGrid, f::FaceField, δyf::CellField)
    for k in 1:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds δyf.data[i, j, k] =  f.data[i, incmod1(j, g.Ny), k] - f.data[i, j, k]
    end
    nothing
end

"""
    δz!(g::RegularCartesianGrid, f::CellField, δzf::FaceField)

Compute the difference \$\\delta_z(f) = f_T - f_B\$ between the top and
bottom cells of a cell-centered field `f` and store it in a face-centered
field `δzf`, assuming both fields are defined on a regular Cartesian grid `g`
with Neumann boundary condition in the \$z\$-direction.
"""
function δz!(g::RegularCartesianGrid, f::CellField, δzf::FaceField)
    for k in 2:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds δzf.data[i, j, k] = f.data[i, j, k-1] - f.data[i, j, k]
    end
    @. δzf.data[:, :, 1] = 0
    nothing
end

"""
    δz!(g::RegularCartesianGrid, f::FaceField, δzf::CellField)

Compute the difference \$\\delta_z(f) = f_T - f_B\$ between the top and
bottom faces of a face-centered field `f` and store it in a cell-centered
field `δzf`, assuming both fields are defined on a regular Cartesian grid `g`
with Neumann boundary condition in the \$z\$-direction.
"""
function δz!(g::RegularCartesianGrid, f::FaceField, δzf::CellField)
    for k in 1:(g.Nz-1), j in 1:g.Ny, i in 1:g.Nx
        @inbounds δzf.data[i, j, k] =  f.data[i, j, k] - f.data[i, j, k+1]
    end
    @. δzf.data[:, :, end] = f.data[:, :, end]
    nothing
end

"""
    avgx(g::RegularCartesianGrid, f::CellField, favgx::FaceField)

Compute the average \$\\overline{\\;f\\;}^x = \\frac{f_E + f_W}{2}\$ between the
eastern and western cells of a cell-centered field `f` and store it in a `g`
face-centered field `favgx`, assuming both fields are defined on a regular
Cartesian grid `g` with periodic boundary conditions in the \$x\$-direction.
"""
function avgx!(g::RegularCartesianGrid, f::CellField, favgx::FaceField)
    for k in 1:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds favgx.data[i, j, k] =  (f.data[i, j, k] + f.data[decmod1(i, g.Nx), j, k]) / 2
    end
end

function avgx!(g::RegularCartesianGrid, f::FaceField, favgx::CellField)
    for k in 1:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds favgx.data[i, j, k] =  (f.data[incmod1(i, g.Nx), j, k] + f.data[i, j, k]) / 2
    end
end

function avgy!(g::RegularCartesianGrid, f::CellField, favgx::FaceField)
    for k in 1:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds favgy.data[i, j, k] =  (f.data[i, j, k] + f.data[i, decmod1(j, g.Ny), k]) / 2
    end
end

function avgy!(g::RegularCartesianGrid, f::FaceField, favgx::CellField)
    for k in 1:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds favgy.data[i, j, k] =  (f.data[i, incmod1(j, g.Ny), k] + f.data[i, j, k]) / 2
    end
end

function avgz!(g::RegularCartesianGrid, f::CellField, favgz::FaceField)
    for k in 2:g.Nz, j in 1:g.Ny, i in 1:g.Nx
        @inbounds favgz.data[i, j, k] =  (f.data[i, j, k] + f.data[i, j, k-1]) / 2
    end
    @. favgz.data[:, :, 1] = 0
    nothing
end

function avgz!(g::RegularCartesianGrid, f::FaceField, favgz::CellField)
    for k in 1:(g.Nz-1), j in 1:g.Ny, i in 1:g.Nx
        favgz.data[i, j, k] =  (f.data[i, j, incmod1(k, g.Nz)] + f.data[i, j, k]) / 2
    end
    @. δf.data[:, :, end] = 0
    nothing
end

"""
    div!(g, fx, fy, fz, δfx, δfy, δfz, div)

Compute the divergence.
"""
function div!(g::RegularCartesianGrid,
              fx::FaceFieldX, fy::FaceFieldY, fz::FaceFieldZ,
              δfx::CellField, δfy::CellField, δfz::CellField,
              div::CellField)

    δx!(g, fx, δfx)
    δy!(g, fy, δfy)
    δz!(g, fz, δfz)

    @. div.data = (1/g.V) * ( g.Ax * δfx.data + g.Ay * δfy.data + g.Az * δfz.data )
    nothing
end

function div!(g::RegularCartesianGrid,
              fx::CellField, fy::CellField, fz::CellField,
              δfx::FaceField, δfy::FaceField, δfz::FaceField,
              div::FaceField)

    δx!(g, fx, δfx)
    δy!(g, fy, δfy)
    δz!(g, fz, δfz)

    @. div.data = (1/g.V) * ( g.Ax * δfx.data + g.Ay * δfy.data + g.Az * δfz.data )
    nothing
end


function div_flux!(g::RegularCartesianGrid, Q::CellField,
                   u::FaceFieldX, v::FaceFieldY, w::FaceFieldY,
                   Qavgx::CellField, Qavgy::CellField, Qavgz::CellField,
                   flx::FaceFieldX, fly::FaceFieldY, flz::FaceFieldZ,
                   div_flux::CellField)
    avgx!(g, Q, Qavgx)
    avgy!(g, Q, Qavgy)
    avgz!(g, Q, Qavgz)

    flx = Aˣ * u * avgˣc2f(Q)
    fly = Aʸ * v * avgʸc2f(Q)
    flz = Aᶻ * w * avgᶻc2f(Q)

    # Imposing zero vertical flux through the top and bottom layers.
    @. flux_z[:, :, 1] = 0
    # @. flux_z[:, :, end] = 0

    (1/Vᵘ) .* (δˣf2c(flux_x) .+ δʸf2c(flux_y) .+ δᶻf2c(flux_z))
end