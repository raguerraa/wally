#!/usr/bin/env python3
"""Rebuild iWalle's explanatory figures (optional docs tooling).

Requires NumPy and Matplotlib. These are not iOS app dependencies.
The examples use the app's current coordinate domain and active operators.
Python's seeded choices make these figures repeatable; the Swift app currently
uses unseeded random generation, so these are illustrations, not saved app seeds.
"""

from pathlib import Path
import random

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

OUT = Path(__file__).resolve().parents[1] / "docs" / "images"
OUT.mkdir(parents=True, exist_ok=True)
BG = "#08060D"
TEXT = "#F7F3FF"
MUTED = "#B2A7C5"
PURPLE = "#D7C5FF"
plt.rcParams.update({"font.family": "DejaVu Sans", "text.color": TEXT,
                     "axes.facecolor": BG, "figure.facecolor": BG})


def grid(width=240, height=420):
    x = np.arange(width, dtype=np.float32) / np.float32(width)
    y = np.arange(height, dtype=np.float32) / np.float32(height)
    return np.meshgrid(x, y)


def byte(value):
    # Swift's default .rounded() rounds positive half-way values upward.
    return np.floor(np.clip(value, 0, 1) * 255 + 0.5).astype(np.uint8)


def image_axis(fig, rect, pixels, title, caption):
    ax = fig.add_axes(rect)
    ax.imshow(pixels, interpolation="nearest", aspect="auto")
    ax.set_axis_off()
    ax.set_title(title, color=PURPLE, fontsize=14, fontweight="bold", pad=14)
    ax.text(0.5, -0.045, caption, transform=ax.transAxes,
            ha="center", va="top", color=MUTED, fontsize=9.5, linespacing=1.5)


def rgb_example():
    x, y = grid()
    pi = np.float32(np.pi)
    channels = [np.abs(np.sin(pi * ((x + y) / 2))),
                np.abs(np.cos(pi * (x * y))),
                (np.abs(np.sin(pi * x)) + np.abs(np.cos(pi * y))) / 2]
    rgb = np.stack([byte(channel) for channel in channels], axis=-1)
    fig = plt.figure(figsize=(13, 7.2), dpi=150)
    fig.text(0.045, 0.94, "Three functions. One pixel at a time.",
             fontsize=23, fontweight="bold")
    fig.text(0.045, 0.89, "Evaluate the same coordinates in three expression trees, then combine their color channels.",
             fontsize=11, color=MUTED)
    captions = ["R(x,y) = abs(sin(π × (x + y) / 2))",
                "G(x,y) = abs(cos(π × x × y))",
                "B(x,y) = (abs(sin(π × x))\n+ abs(cos(π × y))) / 2",
                "RGB = (R, G, B)\nClamp → scale → round"]
    for index, title in enumerate(["RED", "GREEN", "BLUE", "COMBINED"]):
        pixels = rgb.copy()
        if index < 3:
            pixels[:] = 0
            pixels[:, :, index] = rgb[:, :, index]
        image_axis(fig, [0.045 + index * 0.235, 0.22, 0.205, 0.56], pixels,
                   title, captions[index])
    fig.text(0.045, 0.055,
             "Illustrative formulas using iWalle’s active operations with k = π. Coordinates: 0 ≤ x,y < 1; y increases downward.",
             fontsize=10, color=MUTED)
    fig.savefig(OUT / "algorithm-rgb.png", facecolor=BG)
    plt.close(fig)


OPS = ("multiply", "average", "cosine", "sine")


def make_tree(rng, depth):
    op = rng.choice(OPS)
    binary = op in ("multiply", "average")
    if depth == 1:
        return (op, ("x",), ("y",)) if binary else (op, (rng.choice(("x", "y")),))
    # Same branching rules as Swift. The random number stream is Python-specific.
    right = make_tree(rng, depth - 1)
    if binary:
        left = make_tree(rng, depth - 1)
        return (op, left, right)
    return (op, right)


def evaluate(tree, x, y, depth):
    op = tree[0]
    if op == "x":
        return x
    if op == "y":
        return y
    right = evaluate(tree[-1], x, y, depth)
    if op == "multiply":
        return evaluate(tree[1], x, y, depth) * right
    if op == "average":
        return (evaluate(tree[1], x, y, depth) + right) / 2
    scale = np.float32(np.pi / 2 if depth == 1 else np.pi)
    return np.abs(np.sin(right * scale) if op == "sine" else np.cos(right * scale))


def node_count(tree):
    return 1 + sum(node_count(child) for child in tree[1:])


def depth_comparison():
    x, y = grid()
    fig = plt.figure(figsize=(10, 7.7), dpi=150)
    fig.text(0.055, 0.94, "More depth, more room for surprise.",
             fontsize=22, fontweight="bold")
    fig.text(0.055, 0.895,
             "Depth controls nesting. It does not guarantee a busier or more attractive image.",
             fontsize=10.5, color=MUTED)
    for index, (depth, seed) in enumerate([(1, 88), (6, 240), (11, 351)]):
        rng = random.Random(seed)
        trees = [make_tree(rng, depth) for _ in range(3)]
        rgb = np.stack([byte(evaluate(t, x, y, depth)) for t in trees], axis=-1)
        image_axis(fig, [0.055 + index * 0.32, 0.20, 0.25, 0.59], rgb,
                   f"DEPTH {depth}  ·  {(depth - 1) * 10}%",
                   f"{sum(node_count(t) for t in trees)} nodes across three trees\nIndependent generated example")
    fig.text(0.055, 0.055,
             "Reproducible documentation samples using the current Swift generator’s branching and evaluation rules.\n"
             "Their fixed Python seeds belong to this illustration script; the app does not currently save seeds.",
             fontsize=9.5, color=MUTED, linespacing=1.6)
    fig.savefig(OUT / "depth-comparison.png", facecolor=BG)
    plt.close(fig)


if __name__ == "__main__":
    rgb_example()
    depth_comparison()
    for path in sorted(OUT.glob("*.png")):
        print(path)
