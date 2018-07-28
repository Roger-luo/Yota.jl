## tape

const MaybeFunction = Union{Function, Nothing}

mutable struct Tape
    ops::Vector{<:AbstractOp}   # linearized execution graph
    resultid::Int               # id of result variable
    derivs::Dict{Int,Int}       # derivs[var.id] == grad_var.id
    sfields::Dict{Int, Dict}    # mapping of argid -> Dict(struct field paths -> var id)
    compiled::MaybeFunction     # compiled tape or nothing
    meta::Dict{Any,Any}         # additional info useful e.g. for debugging
    Tape() = new(AbstractOp[], -1, Dict(), Dict(), nothing, Dict())
end

function Base.show(io::IO, tape::Tape)
    rev_derivs = Dict((j, i) for (i, j) in tape.derivs)
    # rev_sfields = Dict((var.id, argid) for )
    println(io, "Tape")
    for (i, op) in enumerate(tape.ops)
        hint_deriv = haskey(rev_derivs, i) ? "deriv for %$(rev_derivs[i])" : ""
        # hint_struct = haskey(tape.sfields, ) ?
        hint = isempty(hint_deriv) ? "" : "\t # " * hint_deriv
        println(io, "  $op$hint")
    end
end

Base.getindex(tape::Tape, i...) = getindex(tape.ops, i...)
Base.lastindex(tape::Tape) = lastindex(tape.ops)
Base.length(tape::Tape) = length(tape.ops)
Base.iterate(tape::Tape) = iterate(tape.ops)
Base.iterate(tape::Tape, s) = iterate(tape.ops, s)

"""
Record an operation onto a tape, assign new ID to op's var.
"""
function _record!(tape::Tape, op::AbstractOp)
    push!(tape.ops, op)
    op.var.id = length(tape)
    nothing
end
