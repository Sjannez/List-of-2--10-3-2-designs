# List of combinatorial 2-(10-3-2)-designs
This repository contains a list of combinatorial 2-(10,3,2) designs with and without repeated blocks. These designs were surveyed in [3] and [2] respectively. These articles are difficult to find and, to our knowledge, no digital version of the list of designs is available. We therefore made our own, and share it here for general convenience. This data was used in [1] to disprove the existence of certain Neumaier graphs using binary programming.

There exist 960 2-(10,3,2) designs: 566 with and 394 without repeated blocks. The designs with repeated blocks were recomputed by the authors of [1], hence the format and order of these designs differs from the original list in [2]. This repository contains the following files:

* [repeated_blocks.txt](repeated_blocks.txt) -- list of 2-(10,3,2)-designs with repeated blocks;
* [no_repeated_blocks.txt](repeated_blocks.txt) -- list of 2-(10,3,2)-designs without repeated blocks;
* [repeated_blocks_code.sage](repeated_blocks_code.sage) -- Sage code used to compute the designs with repeated blocks, following the algorithm described in [2].

We use the digits 0-9 to represent the ten points of the designs. Each line of the text files starts with a line number, followed by three sets of thirty digits each, representing the first, second and third entry of the thirty blocks of the design.

<br />
<br />

[1] [A. Abiad, M. De Boeck, and S. Zeijlemaker. On the existence of small strictly Neumaier graphs. arXiv preprint arXiv:2308.15406, 2023.](https://arxiv.org/abs/2308.15406)

[2] B. Ganter, A. Gülzow, R. A. Mathon, and A. Rosa. A complete census of (10,3,2) block designs and of mendelsohn triple systems of order ten. IV. (10, 3, 2) block designs with repeated blocks. _Mathematische Schriften Kassel_, 5/78:211–234, 1978.

[3] C. J. Colbourn, M. J. Colbourn, J. J. Harms, and A. Rosa. A complete census of (10,3,2) block designs and of mendelsohn triple systems of order ten. III. (10, 3, 2) block designs without repeated blocks. _Congressus Numerantium_, 37:211–234, 1983.
