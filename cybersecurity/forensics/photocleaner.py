#!/usr/bin/env python3

"""
PhotoCleaner: A terminal-based utility to manage EXIF metadata in images.

Author: SATANMYNINJAS
License: MIT
"""

import os
import random
import piexif
import curses
from PIL import Image

def zero_out_exif(image_path):
    """
    Remove all EXIF metadata from a JPEG image.

    Args:
        image_path (str): Path to the image file.

    Returns:
        str: Status message indicating success or failure.
    """
    try:
        img = Image.open(image_path)
        img.save(image_path, "jpeg", exif=piexif.dump({}))
        return f"[DONE] Cleared EXIF data for: {image_path}"
    except Exception as e:
        return f"[!] Error clearing EXIF for {image_path}: {e}"


def randomize_exif(image_path):
    """
    Replace EXIF metadata in an image with randomized junk values.

    Args:
        image_path (str): Path to the image file.

    Returns:
        str: Status message indicating success or failure.
    """
    try:
        img = Image.open(image_path)
        exif_bytes = img.info.get("exif", b"")

        if not exif_bytes:
            return f"[!] No EXIF data to randomize: {image_path}"

        try:
            exif_dict = piexif.load(exif_bytes)
        except Exception:
            return f"[!] Error parsing EXIF for {image_path}: Invalid EXIF data"

        for ifd in exif_dict:
            for tag in exif_dict[ifd]:
                val = exif_dict[ifd][tag]
                if isinstance(val, bytes):
                    exif_dict[ifd][tag] = bytes(random.choices(b"abcdefghijklmnopqrstuvwxyz0123456789", k=10))
                elif isinstance(val, (int, float)):
                    exif_dict[ifd][tag] = random.randint(0, 9999)

        img.save(image_path, "jpeg", exif=piexif.dump(exif_dict))
        return f"[DONE] Randomized EXIF data for: {image_path}"

    except Exception as e:
        return f"[!] Error randomizing EXIF for {image_path}: {e}"


def read_exif_data(image_path):
    """
    Read and format EXIF metadata from a JPEG image.

    Args:
        image_path (str): Path to the image file.

    Returns:
        str: Human-readable formatted EXIF data or error message.
    """
    try:
        img = Image.open(image_path)
        exif_data = img.info.get("exif", b"")
        exif_dict = piexif.load(exif_data) if exif_data else {}

        if not exif_dict:
            return f"[!] No EXIF data found: {image_path}"

        output_lines = [f"[DONE] EXIF for {image_path}:"]
        for ifd in exif_dict:
            for tag, value in exif_dict[ifd].items():
                tag_name = piexif.TAGS[ifd].get(tag, {"name": str(tag)})["name"]
                if isinstance(value, bytes):
                    value = value.decode(errors="ignore")
                output_lines.append(f"  {tag_name}: {value}")

        return "\n".join(output_lines)

    except Exception as e:
        return f"[!] Error reading EXIF for {image_path}: {e}"


def process_directory(directory, mode):
    """
    Apply a selected EXIF processing mode to all images in a directory.

    Args:
        directory (str): Path to the directory containing image files.
        mode (str): Operation mode - 'zero', 'random', or 'read'.

    Returns:
        list: Status messages for each processed file.
    """
    results = []
    for file in os.listdir(directory):
        if file.lower().endswith((".jpg", ".jpeg", ".png")):
            path = os.path.join(directory, file)
            if mode == "zero":
                results.append(zero_out_exif(path))
            elif mode == "random":
                results.append(randomize_exif(path))
            elif mode == "read":
                results.append(read_exif_data(path))
    return results


def tui(stdscr):
    """
    Text-based User Interface (TUI) for PhotoCleaner using curses.

    Args:
        stdscr: curses screen object passed from wrapper().
    """
    curses.curs_set(0)
    stdscr.clear()

    BANNER = r"""
  ______________       _____      ______________
  ___  __ \__  /_________  /________  ____/__  /__________ ____________________
  __  /_/ /_  __ \  __ \  __/  __ \  /    __  /_  _ \  __ `/_  __ \  _ \_  ___/
  _  ____/_  / / / /_/ / /_ / /_/ / /___  _  / /  __/ /_/ /_  / / /  __/  /
  /_/     /_/ /_/\____/\__/ \____/\____/  /_/  \___/\__,_/ /_/ /_/\___//_/

               By: Keith Michelangelo Fernandez
    A tool for scrubbing EXIF metadata on bulk media files, photos, etc.
    """

    def display_menu():
        stdscr.clear()
        stdscr.addstr(1, 2, BANNER, curses.A_BOLD)
        stdscr.addstr(11, 2, "[*] Welcome to the PhotoCleaner!")
        stdscr.addstr(12, 2, "[?] Select an option:")
        stdscr.addstr(14, 4, "[1] - Zero out all EXIF data.")
        stdscr.addstr(15, 4, "[2] - Randomize EXIF data.")
        stdscr.addstr(16, 4, "[3] - Read existing EXIF data.")
        stdscr.addstr(17, 4, "[q] - Quit.")
        stdscr.refresh()

    while True:
        display_menu()
        key = stdscr.getch()

        if key == ord('1'):
            results = process_directory(os.getcwd(), "zero")
        elif key == ord('2'):
            results = process_directory(os.getcwd(), "random")
        elif key == ord('3'):
            results = process_directory(os.getcwd(), "read")
        elif key in [ord('q'), ord('Q')]:
            break
        else:
            continue

        stdscr.clear()
        stdscr.addstr(2, 2, "[DONE] Operation Results:")
        line = 4
        for res in results[:curses.LINES - 6]:
            for subline in res.split("\n"):
                if line < curses.LINES - 2:
                    stdscr.addstr(line, 4, subline)
                    line += 1
        stdscr.addstr(line + 1, 2, "[*] Press any key to return to the menu...")
        stdscr.getch()


if __name__ == "__main__":

