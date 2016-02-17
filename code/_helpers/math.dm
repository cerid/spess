// Greatest Common Divisor - Euclid's algorithm
/proc/gcd(a, b)
	return b ? gcd(b, a % b) : a
