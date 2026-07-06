"""Generate bell.wav for First Word — a warm two-strike chapel bell, loopable."""
import math
import struct
import wave

SR = 44100
DUR = 3.2
N = int(SR * DUR)

# Bell partials: fundamental + inharmonic overtones (freq, amplitude, decay rate)
PARTIALS = [
    (880.0, 0.55, 1.6),   # A5
    (1108.7, 0.30, 2.0),  # C#6
    (1318.5, 0.22, 2.4),  # E6
    (1760.0, 0.12, 3.2),  # A6 shimmer
    (587.3, 0.18, 1.2),   # D5 undertone warmth
]

def strike(t):
    if t < 0:
        return 0.0
    s = 0.0
    for f, a, d in PARTIALS:
        s += a * math.exp(-d * t) * math.sin(2 * math.pi * f * t)
    # Soft attack over the first 8ms so it doesn't click
    if t < 0.008:
        s *= t / 0.008
    return s

samples = []
for i in range(N):
    t = i / SR
    v = strike(t) + 0.7 * strike(t - 1.5)   # second, softer strike at 1.5s
    # Gentle fade at the tail so the loop point is silent
    if t > DUR - 0.35:
        v *= max(0.0, (DUR - t) / 0.35)
    samples.append(max(-1.0, min(1.0, v * 0.55)))

with wave.open(r"C:\dev\verse-alarm\native\FirstWord\Resources\bell.wav", "w") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(b"".join(struct.pack("<h", int(s * 32767)) for s in samples))

print("bell.wav written")
