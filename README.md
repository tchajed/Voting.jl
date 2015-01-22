# Voting

[![Build Status](https://travis-ci.org/tchajed/Voting.jl.svg?branch=master)](https://travis-ci.org/tchajed/Voting.jl)
[![Coverage Status](https://coveralls.io/repos/tchajed/Voting.jl/badge.svg?branch=master)](https://coveralls.io/r/tchajed/Voting.jl?branch=master)

Implementations of several voting schemes (technically social choice functions)
in Julia. Inspired by the Coursera "Game Theory II: Advanced Applications"
course from Stanford/UBC: terminology mirrors the course.

All schemes currently require a strict set of preferences; that is, an ordering
over all the candidates, with no indifferences. This could eventually be
relaxed for some of the voting schemes or extended to weak or partial preferences.

# Schemes

- plurality: The candidate with the most top votes wins.
- plurality with elimination: Vote in rounds. In each round, count the top
  candidate for each agent and drop the lowest-ranked candidate from the race.
- Borda rule: For each agent, assign each candidate points based on ranking as
  follows: the lowest ranked candidate gets 0 points, the next lowest gets 1,
  and so on (for example, if an agent prefers A to C to D, then A gets 2 points,
  C gets 1 point, and D gets 0 points). The candidate with the most total points
  wins.
- pairwise (successive) elimination: Given an ordering of the candidates
  (called an agenda), pair the first two candidates and conduct a plurality
  vote between them. The winner of this election the faces the next candidate in
  the agenda, and so on.

The methods that implement these schemes are (currently) social choice
functions: that is, they return the winner, as opposed to a social welfare
function that would rank the candidates. However, there is still a possibility
of ties, so every function returns a list of winners.

# Functions

Two other functions are provided to analyze voting results.

- `condorcet`: determine the Condorcet winner, defined as a candidate that wins
  against every other candidate in pairwise elections. There is not always a
  Condorcet winner, so this function returns a list with either the Condorcet
  winner or nothing.
- `pareto_dominates`: determine if candidate `a` Pareto-dominates candidate
  `b`. This is defined as every agent preferring `a` to `b`.
