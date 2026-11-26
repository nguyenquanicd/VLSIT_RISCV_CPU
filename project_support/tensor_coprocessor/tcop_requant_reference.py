"""Exact rational reference for REQUANT8 and fused INT8 ARGMAX scores."""

from dataclasses import dataclass
from fractions import Fraction
from struct import pack, unpack


@dataclass(frozen=True)
class Requant8:
    multiplier: int
    exponent: int

    def __post_init__(self):
        if not 0x40000000 <= self.multiplier <= 0x7FFFFFFF:
            raise ValueError("REQUANT8 multiplier is not normalized")
        if not -31 <= self.exponent <= 31:
            raise ValueError("REQUANT8 exponent is outside [-31, 31]")

    @classmethod
    def from_bytes(cls, record: bytes) -> "Requant8":
        if len(record) != 8 or record[5:] != bytes(3):
            raise ValueError("REQUANT8 requires an eight-byte record with zero reserved bytes")
        return cls(*unpack("<Ib3x", record))

    def to_bytes(self) -> bytes:
        return pack("<Ib3x", self.multiplier, self.exponent)

    @classmethod
    def from_ratio(cls, ratio: Fraction) -> "Requant8":
        """Encode an exact positive scale ratio using DEC-054 rounding."""
        if ratio <= 0:
            raise ValueError("requantization ratio must be positive")
        # Find floor(log2(ratio)) exactly before rounding the mantissa.
        power = ratio.numerator.bit_length() - ratio.denominator.bit_length()
        if ratio < Fraction(2) ** power:
            power -= 1
        exponent = power + 1
        multiplier = round(ratio * Fraction(2) ** (31 - exponent))
        if multiplier == 1 << 31:
            multiplier = 1 << 30
            exponent += 1
        return cls(multiplier, exponent)

    def score(self, accumulator: int) -> Fraction:
        """Return an exact compare-domain score before INT8 narrowing."""
        return Fraction(accumulator * self.multiplier, 1 << (31 - self.exponent))

    def requantize(self, accumulator: int) -> int:
        """Round ties to even and saturate to the signed INT8 range."""
        return min(127, max(-128, round(self.score(accumulator))))


def fused_argmax_index(candidates) -> int:
    """Return the lowest winning index from (accumulator, Requant8) pairs."""
    scores = ((coeff.score(accumulator), -index)
              for index, (accumulator, coeff) in enumerate(candidates))
    return -max(scores)[1]


def lookup_int8_lut(value: int, lut: bytes) -> int:
    """Read an INT8 LUT using the unsigned encoding of the signed input."""
    if not isinstance(lut, bytes) or len(lut) != 256:
        raise ValueError("LUT requires exactly 256 signed INT8 encodings")
    result = lut[value & 0xFF]
    return result - 256 if result & 0x80 else result


def gemm_int8_epilogue(accumulator, coefficient: Requant8, *,
                       initial_c=None, bias=None, residual=None, activation="none", lut=None):
    """Apply the OP-001/008 INT8 addends, rounding, saturation and activation."""
    for addend in (initial_c, bias, residual):
        if addend is not None:
            if type(addend) is not int or not -128 <= addend <= 127:
                raise ValueError("GEMM addends must be signed INT8 accumulator-scale values")
            accumulator += addend
    output = coefficient.requantize(accumulator)
    if activation == "lut8":
        return lookup_int8_lut(output, lut)
    if lut is not None or activation not in ("none", "relu"):
        raise ValueError("invalid GEMM activation configuration")
    return max(0, output) if activation == "relu" else output
