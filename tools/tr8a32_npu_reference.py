"""Reference model for the fixed TR-8-A32N INT8 2x2 NPU."""

INT32_MIN = -(1 << 31)
INT32_MAX = (1 << 31) - 1


def saturate_int32(value: int) -> int:
    return max(INT32_MIN, min(INT32_MAX, value))


def matrix_2x2(
    inputs: tuple[int, int, int, int],
    weights: tuple[int, int, int, int],
    biases: tuple[int, int],
    relu: bool = False,
    saturate: bool = False,
) -> tuple[int, int, int, int]:
    """Return C = A*B + bias using the RTL's signed 2x2 layout."""
    a00, a01, a10, a11 = inputs
    b00, b01, b10, b11 = weights
    bias0, bias1 = biases
    values = (
        bias0 + a00 * b00 + a01 * b10,
        bias1 + a00 * b01 + a01 * b11,
        bias0 + a10 * b00 + a11 * b10,
        bias1 + a10 * b01 + a11 * b11,
    )
    if saturate:
        values = tuple(saturate_int32(value) for value in values)
    if relu:
        values = tuple(max(0, value) for value in values)
    return values


def run_self_test() -> None:
    assert matrix_2x2(
        (1, 2, 3, 4), (5, 6, 7, 8), (1, 2)
    ) == (20, 24, 44, 52)
    assert matrix_2x2(
        (1, 2, 3, 4), (5, 6, 7, 8), (-256, 2), relu=True, saturate=True
    ) == (0, 24, 0, 52)
    assert matrix_2x2(
        (127, 127, 127, 127), (127, 127, 127, 127),
        (INT32_MAX, INT32_MIN), saturate=True
    ) == (INT32_MAX, INT32_MIN + 32258,
          INT32_MAX, INT32_MIN + 32258)


if __name__ == "__main__":
    run_self_test()
    print("TR-8-A32N NPU REFERENCE TESTS PASSED")
