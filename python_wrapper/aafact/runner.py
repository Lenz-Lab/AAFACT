from __future__ import annotations

import subprocess
from pathlib import Path


class AAFACTError(RuntimeError):
    pass


def run_aafact(input_dir: str | Path, exe_path: str | Path) -> Path:
    """
    Run the compiled AAFACT executable on a folder of bone models.

    Parameters
    ----------
    input_dir : path-like
        Folder containing bone model files.
    exe_path : path-like
        Full path to the compiled AAFACT executable (AAFACT.exe on Windows).

    Returns
    -------
    Path
        Path to the Excel output (CoordinateSystem_<folder>.xlsx) if found.

    Raises
    ------
    AAFACTError
        If the executable is missing or AAFACT fails.
    """
    input_dir = Path(input_dir)
    output_dir = Path(input_dir)
    exe_path = Path(exe_path)

    if not exe_path.exists():
        raise AAFACTError(f"AAFACT executable not found: {exe_path}")

    if not input_dir.is_dir():
        raise AAFACTError(f"Input folder not found: {input_dir}")

    output_dir.mkdir(parents=True, exist_ok=True)

    # Run AAFACT: AAFACT.exe "<input>" "<output>"
    cmd = [str(exe_path), str(input_dir)]

    try:
        proc = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )
    except Exception as e:
        raise AAFACTError(f"Failed to start AAFACT: {e}") from e

    if proc.returncode != 0:
        raise AAFACTError(
            "AAFACT failed.\n"
            f"Command: {cmd}\n\n"
            f"STDOUT:\n{proc.stdout}\n\n"
            f"STDERR:\n{proc.stderr}\n"
        )

    # Try to find the expected Excel output in output_dir
    # Your CLI creates: CoordinateSystem_<inputFolderName>.xlsx
    expected = output_dir / f"CoordinateSystem_{input_dir.name}.xlsx"
    if expected.exists():
        return expected

    # If name differs, fall back to “any CoordinateSystem_*.xlsx”
    matches = sorted(output_dir.glob("CoordinateSystem_*.xlsx"))
    if matches:
        return matches[-1]

    raise AAFACTError(
        "AAFACT completed but no Excel output was found.\n"
        f"Looked for: {expected}\n"
        f"Output folder: {output_dir}\n"
        f"STDOUT:\n{proc.stdout}\n"
    )
