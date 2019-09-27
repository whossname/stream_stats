defmodule StreamStatsTest do
  use ExUnit.Case
  use PropCheck
  doctest StreamStats

  property "single value returns count 1, average equal to the value, 0 second moment" do
    forall value <- float() do
      {1, value, 0} == StreamStats.push_value(value, nil)
    end
  end

  property "standard deviation never negative" do
    forall values <- non_empty(list(float())) do
      {count, _, m2} = StreamStats.reduce(values)
      m2 >= 0 and count > 0
    end
  end

  property "stats calculated correctly" do
    forall values <- non_empty(list(float())) do
      count = Enum.count(values)
      total = Enum.sum(values)
      mean = total / count
      stddev = calc_std_dev(values, count, mean)

      stats = StreamStats.reduce(values)
      stream_stddev = StreamStats.standard_deviation(stats)
      {stream_count, stream_mean, _} = stats

      assert count == stream_count
      assert_in_delta(mean, stream_mean, 0.00000000001)
      assert_in_delta(stddev, stream_stddev, 0.00000000001)
    end
  end

  property "merging two streams gives same result as one stream" do
    forall {values_1, values_2} <- {non_empty(list(float())), non_empty(list(float()))} do
      {c1, a1, m1} = StreamStats.reduce(values_1 ++ values_2)

      stream_1 = StreamStats.reduce(values_1)
      stream_2 = StreamStats.reduce(values_2)
      {c2, a2, m2} = StreamStats.combine(stream_1, stream_2)

      assert c1 == c2
      assert_in_delta(a1, a2, 0.00000000001)
      assert_in_delta(m1, m2, 0.000000001)
    end
  end

  defp calc_std_dev(_, 0, _), do: 0
  defp calc_std_dev(_, 1, _), do: 0

  defp calc_std_dev(values, count, mean) do
    sq_sum =
      Enum.map(values, fn val ->
        d = val - mean
        d * d
      end)
      |> Enum.sum()

    (sq_sum / (count - 1))
    |> :math.sqrt()
  end
end
