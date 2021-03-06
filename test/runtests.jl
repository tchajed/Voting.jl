using Voting
using Base.Test

## Low-level tests

# Construction
@test vote(3, 1, 2) == Vote([3, 1, 2], 1)
@test 2 * vote(3, 1, 2) == Vote([3, 1, 2], 2)
@test 1 * vote(3, 1, 2) == vote(3, 1, 2)
@test 2 * vote(3, 1, 2) == 2 * vote(3, 1, 2)
@test hash(vote(3, 1, 2)) == hash(vote(3, 1, 2))
@test hash(2 * vote(3, 1, 2)) != hash(vote(3, 1, 2))
ballot = [:A, :B, :C]
@test_throws ArgumentError Votes(ballot, vote(1, 2, 3, 4))
@test_throws ArgumentError Votes(ballot, vote(1, 2))
@test_throws ArgumentError Votes(ballot, vote(1, 2, 4))
@test_throws ArgumentError Votes(ballot, vote(1, 2, 2))

# Iteration
@test 3 == length(vote(3, 1, 2))
@test [3, 1, 2] == [c for c in 4 * vote(3, 1, 2)]
@test [3, 1, 2] == collect(vote(3, 1, 2))

votes = Votes([:A, :B, :C],
        [1 2 3;
        1 3 2;
        1 3 2;
        3 2 1;
        3 2 1])
@test 5 == length(votes)
@test 5 == length([c for c in votes])
@test 5 == length(collect(votes))
@test [ vote(1, 2, 3),
        vote(1, 3, 2),
        vote(1, 3, 2),
        vote(3, 2, 1),
        vote(3, 2, 1) ] == collect(votes)
@test [:A] == plurality(votes)
@test [:A, :C] == borda(votes)

votes = Votes([32, 64, 12],
    10 * vote(3, 1, 2),
    3 * vote(1, 2, 3),
    3 * vote(1, 3, 2))
@test 3 == length(votes)
@test [12] == plurality(votes)

votes1 = Votes([:A, :B], [vote(1, 2), vote(2, 1)])
votes2 = Votes([:A, :B], vote(1, 2), vote(2, 1))
@test votes1 == votes2
@test hash(votes1) == hash(votes2)
@test hash(votes1) != hash(votes)

@test "2× [:A,:B]\n1× [:B,:A]\n" ==
    string(Votes([:A, :B], 2*vote(1, 2), vote(2, 1)))

## Examples taken from Coursera "Game Theory II: Advanced Applications" course
## from Stanford/UBC.

unit12 = Votes([:A, :B, :C, :D],
       [2 3 1 4;
       2 4 3 1;
       4 3 1 2;
       1 4 2 3;
       1 4 3 2])
@test [] == condorcet(unit12)
@test [:A, :B] == sort(plurality(unit12))
@test [:D] == borda(unit12)

paradox = Votes([:A, :B, :C],
        499 * vote(1, 2, 3),
        3 * vote(2, 3, 1),
        498 * vote(3, 2, 1))
@test [:B] == condorcet(paradox)
@test [:A] == plurality(paradox)
@test [:C] == plurality_with_elimination(paradox)

iia_paradox = Votes([:A, :B, :C],
        35 * vote(1, 3, 2),
        33 * vote(2, 1, 3),
        32 * vote(3, 2, 1))
@test [:A] == plurality(iia_paradox)
@test [:A] == borda(iia_paradox)

iia_paradox_without_c = Voting.delete(iia_paradox, 3)
@test [:B] == plurality(iia_paradox_without_c)
@test [:B] == borda(iia_paradox_without_c)

@test [:C] == pairwise_elimination(iia_paradox, [:A, :B, :C])
@test [:B] == pairwise_elimination(iia_paradox, [:A, :C, :B])
@test [:A] == pairwise_elimination(iia_paradox, [:B, :C, :A])

pe_paradox = Votes([:A, :B, :C, :D],
        [2 4 3 1;
        1 2 4 3;
        3 1 2 4])
@test [:D] == pairwise_elimination(pe_paradox, [:A, :B, :C, :D])
# :B Pareto-dominates :D
@test pareto_dominates(pe_paradox, :B, :D)

unit13 = Votes([:A, :B, :C, :D],
        [2 3 1 4;
        2 4 3 1;
        4 3 1 2;
        1 4 2 3;
        1 4 3 2])
@test [:D] == pairwise_elimination(unit13, [:A, :B, :C, :D])
@test [:A] == pairwise_elimination(unit13, [:D, :C, :B, :A])
ballot = unit13.ballot
for first in ballot, other in ballot
    @test !pareto_dominates(unit13, first, other)
end

unit16first = Votes([:a, :b, :c],
    3 * vote(1, 2, 3),
    2 * vote(2, 3, 1),
    2 * vote(3, 2, 1))
@test [:a] == plurality(unit16first)
unit16second = Votes([:a, :b, :c],
    3 * vote(1, 2, 3),
    2 * vote(2, 3, 1),
    2 * vote(2, 1, 3))
@test [:b] == plurality(unit16second)
