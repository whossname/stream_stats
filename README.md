# StreamStats

Enables concurrent calculation of count, mean and standard deviation.
New values can be aggregated into an existing stat tuple and two stat
tuples can be merged into one.

Inspired by the following article by John D. Cook:
https://www.johndcook.com/blog/skewness_kurtosis/

## Installation

The package can be installed by adding `stream_stats` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stream_stats, "~> 0.1.0"}
  ]
end
```

## Example usage

Given two lists of numbers `values_1` and `values_2` the two lists can be
aggregated independently, then combined into a single stats tuple:

```elixir
  stream_1 = StreamStats.reduce(values_1)
  stream_2 = StreamStats.reduce(values_2)
  stats = StreamStats.combine(stream_1, stream_2)

  {count, mean, _m2} = stats
  std_dev = StreamStats.standard_deviation(stats)
```
