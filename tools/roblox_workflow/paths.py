"""Keep recordings and command logs out of the source checkout."""
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]

def external_path(value):
    path = Path(value).expanduser().resolve()
    if path == REPO or path.is_relative_to(REPO):
        raise ValueError('Choose an evidence/build directory outside the repository checkout')
    return path
