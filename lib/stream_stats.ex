defmodule StreamStats do
  @moduledoc """
  Enables concurrent calculation of count, mean and standard deviation.
  New values can be aggregated into an existing stat tuple and two stat
  tuples can be merged into one.

  Inspired by the following article by John D. Cook:
  https://www.johndcook.com/blog/skewness_kurtosis/
  """

  @type t() :: {count(), mean(), m2()}

  @type count() :: Integer.t()
  @type mean() :: number()
  @type m2() :: number()

  @doc """
  Adds a value to the aggregated stats tuple. Implemented as Welford's Online algorithm.

  https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Welford's_Online_algorithm
  """
  @spec push_value(number(), nil | t()) :: t()
  def push_value(value, nil), do: {1, value, 0}

  def push_value(value, {prev_count, prev_mean, prev_m2}) do
    count = prev_count + 1
    prev_delta = value - prev_mean
    mean = prev_mean + prev_delta / count
    new_delta = value - mean
    m2 = prev_m2 + prev_delta * new_delta

    {count, mean, m2}
  end

  @doc """
  Merges two stats tuples. Implemented as Chan's Parallel Algorithm

  https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Parallel_algorithm
  """
  @spec combine_stats(nil | t(), t()) :: t()

  def combine_stats({_, _, _} = stats_a, nil), do: stats_a
  def combine_stats(nil, {_, _, _} = stats_b), do: stats_b

  def combine_stats({count_a, mean_a, m2_a}, {count_b, mean_b, m2_b}) do
    count = count_a + count_b
    delta = mean_b - mean_a

    # I think this way of calculating the mean is more stable than the obvious way
    mean = mean_a + delta * count_b / count

    m2 = m2_a + m2_b + delta * delta * count_a * count_b / count

    {count, mean, m2}
  end

  @doc """
  Aggregates the values in a list to a stats tuple.
  """
  @spec reduce(Enum.t(), t() | nil) :: any()
  def reduce(values, stats \\ nil) do
    Enum.reduce(values, stats, &combine/2)
  end


  @doc """
  First argument can be a number or stats tuple.
  """
  @spec combine(number() | t(), t()) :: t()
  def combine({_, _, _} = stats_a, stats_b), do: combine_stats(stats_a, stats_b)
  def combine(value, stats), do: push_value(value, stats)

  @doc """
  Calculates the variance using a stats tuple.
  """
  @spec variance(t()) :: number()
  def variance(stats) do
    {count, _mean, m2} = stats

    if count <= 1 do
      0
    else
      m2 / (count - 1.0)
    end
  end

  @doc """
  Calculates the standard deviation using a stats tuple.
  """
  @spec standard_deviation(t()) :: number()
  def standard_deviation(stats) do
    :math.sqrt(variance(stats))
  end
end
