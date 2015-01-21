module Voting

export  Vote,
        Votes,
        Ballot,
        vote,

        pareto_dominates,
        condorcet,

        plurality,
        plurality_with_elimination,
        borda,
        pairwise_elimination

import Base: length, start, done, next, show, ==, hash

immutable Vote
    order::Array{Int64, 1}
    weight::Int64
end

==(v1::Vote, v2::Vote) = v1.order == v2.order && v1.weight == v2.weight
hash(v::Vote, h::Uint64) = hash(v.order, hash(v.weight, h))

# Iterate over order
start(vote::Vote) = 1
done(vote::Vote, index) = index > length(vote.order)
next(vote::Vote, index) = (vote.order[index], index+1)

# Construction
vote(order::Array{Int64, 1}) = Vote(order, 1)
vote(order::Int64...) = Vote(collect(order), 1)
*(v::Vote, count::Int) = Vote(v.order, v.weight * count)
*(count::Int, v::Vote) = v * count

getrank(v::Vote, a) = findfirst(v.order, a)
prefers(v::Vote, a, b) = getrank(v, a) < getrank(v, b)

function delete(v::Vote, a)
    order = map(v.order[v.order .!= a]) do c
        c > a ? c-1 : c
    end
    Vote(order, v.weight)
end

immutable Ballot{T}
    candidates::Array{T, 1}
end

==(b1::Ballot, b2::Ballot) = b1.candidates == b2.candidates
hash(b::Ballot, h::Uint64) = hash(b.candidates, h)

getindex(b::Ballot, v::Vote) = b.candidates[v.order]
getindex(b::Ballot, i) = b.candidates[i]

immutable Votes{T}
    ballot::Ballot{T}
    votes::Array{Vote, 1}
end

function show(io::IO, votes::Votes)
    for v in votes
        v_candidates = votes.ballot[v]
        print(io, "$(v.weight)× $(v_candidates)\n")
    end
end

length(v::Vote) = length(v.order)
length(b::Ballot) = length(b.candidates)

function Votes{T}(b::Ballot{T}, votes::Array{Vote, 1})
    l = length(b)
    for v in votes
        if length(v) != l
            throw(ArgumentError("unexpected vote of length $(length(v)) != $l"))
        end
        if sort(v.order) != collect(1:l)
            throw(ArgumentError("order $(v.order) is not a permutation"))
        end
    end
    return Votes{T}(b, votes)
end

# TODO(tchajed): provide a conversion (convert) from Array{T, 1} to Ballot{T}

function Votes{T}(candidates::Array{T, 1}, votes...)
    Votes(Ballot(candidates), collect(votes))
end

function Votes{T}(candidates::Array{T, 1}, a::Array{Int64, 2})
    m = size(a, 1)
    votes = map(1:m) do row
        ordering = collect(a[row,:])
        vote(ordering)
    end
    return Votes(candidates, votes...)
end

length{T}(votes::Votes{T}) = length(votes.votes)
start(votes::Votes) = 1
done(votes::Votes, index) = index > length(votes.votes)
next(votes::Votes, index) = (votes.votes[index], index+1)
==(votes1::Votes, votes2::Votes) = (votes1.ballot == votes2.ballot) &&
    (votes1.votes == votes2.votes)
hash(votes::Votes, h::Uint64) = hash(votes.ballot, hash(votes.votes, h))

function delete(votes::Votes, i)
    n = length(votes.ballot)
    selection = [1:i-1, i+1:n]
    return Votes(Ballot(votes.ballot[selection]),
    [delete(v, i) for v in votes])
end

function plurality{T}(votes::Votes{T})
    n = length(votes.ballot)
    counts = zeros(n)
    for v in votes
        counts[first(v)] += v.weight
    end
    winners = find(counts .== maximum(counts))
    return votes.ballot[winners]
end

function plurality_with_elimination{T}(votes::Votes{T})
    n = length(votes.ballot)
    if n <= 2
        return plurality(votes)
    end
    counts = zeros(n)
    for v in votes
        counts[first(v)] += v.weight
    end
    loser = indmin(counts)
    return plurality_with_elimination(delete(votes, loser))
end

# TODO(tchajed): handle ties in choice functions that use this
function prefer{T}(votes::Votes{T}, a, b)
    count_a = 0
    count_b = 0
    for v in votes
        if prefers(v, a, b)
            count_a += v.weight
        else
            count_b += v.weight
        end
    end
    return count_a > count_b
end

function pareto_dominates{T}(votes::Votes{T}, a, b)
    ai = findfirst(votes.ballot, a)
    bi = findfirst(votes.ballot, b)
    all(v -> prefers(v, ai, bi), votes)
end

function pairwise_elimination{T}(votes::Votes{T}, agenda::Array{T, 1})
    indices = [findfirst(votes.ballot, c) for c in agenda]
    while length(indices) > 1
        a = indices[1]
        b = indices[2]
        winner = prefer(votes, a, b) ? a : b
        indices = [winner, indices[3:end]]
    end
    return [votes.ballot[indices[1]]]
end

function borda{T}(votes::Votes{T})
    n = length(votes.ballot)
    counts = zeros(n)
    for v in votes, c in 1:n
        borda_count = (n - getrank(v, c)) * v.weight
        counts[c] += borda_count
    end
    winners = find(counts .== maximum(counts))
    return votes.ballot[winners]
end

function condorcet{T}(votes::Votes{T})
    n = length(votes.ballot)
    for c in 1:n
        if all(o -> prefer(votes, c, o), [1:c-1, c+1:n])
            return votes.ballot[[c]]
        end
    end
    return []
end

end
