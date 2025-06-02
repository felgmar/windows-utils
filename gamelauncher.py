import subprocess
import re
import sys
import argparse

def __get_guid_pattern() -> re.Pattern[str]:
    """
    Get the regex pattern for matching GUIDs.
    Returns:
        str: The regex pattern for GUIDs.
    """
    return re.compile(
        r"([0-9a-fA-F\-]{36})\s+\((.*?)\)",
        re.IGNORECASE
    )

def __get_active_power_scheme():
    """
    Get the active power scheme on Windows.
    Returns:
        str: The active power scheme GUID.
    """
    import subprocess
    import re

    active_power_scheme: dict[str, str] = {}

    GUID_PATTERN: re.Pattern[str] = __get_guid_pattern()

    try:
        result: subprocess.CompletedProcess[str] = subprocess.run(
            ['powercfg', '/getactivescheme'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )

        output: str = repr(result.stdout + result.stderr)
        match = re.search(GUID_PATTERN, output)

        if not match:
            raise ValueError("No active power scheme found.")

        active_power_scheme[match.group(2)] = match.group(1)
        return active_power_scheme
    except subprocess.CalledProcessError as e:
        raise e

def __get_available_power_schemes() -> dict[str, str]:
    """
    Get all the available power schemes on your system.
    Returns:
        dict[str, str]: A dictionary of available power scheme names and their GUIDs.
    """
    power_schemes: dict[str, str] = {}

    POWER_SCHEME_PATTERN: re.Pattern[str] = __get_guid_pattern()

    try:
        result: subprocess.CompletedProcess[str] = subprocess.run(
            ['powercfg', '/list'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        output: str = repr(result.stdout + result.stderr)
        available_power_schemes = re.finditer(POWER_SCHEME_PATTERN, output)

        if not available_power_schemes:
            raise ValueError("No power schemes found.")

        for match in available_power_schemes:
            power_schemes[match.group(2)] = match.group(1)
        return power_schemes
    except subprocess.CalledProcessError as e:
        raise e
    except Exception as e:
        raise e

def __run_process(command: list[str]) -> None:
    """
    Run a command in a subprocess and return the result.
    Args:
        command (list[str]): The command to run.
    Returns:
        subprocess.CompletedProcess[str]: The result of the command.
    """
    try:
        process = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        return process.check_returncode()
    except subprocess.CalledProcessError as e:
        raise e

def change_power_scheme(power_scheme: str) -> int:
    """
    Changes the current power scheme to the specified one.
    Returns:
        int: The exit code of the process.
    """
    exit_code: int = 0

    ACTIVE_POWER_SCHEME: dict[str, str] = __get_active_power_scheme()
    AVAILABLE_POWER_SCHEMES: dict[str, str] = __get_available_power_schemes()

    if power_scheme not in AVAILABLE_POWER_SCHEMES:
        raise ValueError(f"Power scheme '{power_scheme}' is not available.")

    if power_scheme in ACTIVE_POWER_SCHEME:
        print(f"Power scheme '{power_scheme}' is already active.")
        return 2

    try:
        result = subprocess.run(
            ['powercfg', '/setactive', AVAILABLE_POWER_SCHEMES[power_scheme]],
            check=True
        )
        exit_code = result.returncode
        return exit_code
    except subprocess.CalledProcessError as e:
        raise e
    except Exception as e:
        raise e
    finally:
        if exit_code == 0:
            print(f"Power scheme set to {power_scheme}")

argparser = argparse.ArgumentParser()

try:
    available_power_schemes: dict[str, str] = __get_available_power_schemes()
    argparser.add_argument("-p",
                           "--power-scheme",
                           action="store",
                           help="Specify the power scheme to use. Available modes are: " +
                            ', '.join(available_power_schemes),
                           default="Balanced",
                           choices=available_power_schemes)
    args = argparser.parse_args()
except Exception as e:
    raise e

if __name__ == "__main__":
    try:
        if len(sys.argv[1:]) == 0:
            raise ValueError("No command to run.")

        if args.power_scheme:
            change_power_scheme(args.power_scheme)
        else:
            change_power_scheme("High performance")

        __run_process(sys.argv[1:])

        change_power_scheme("Balanced")
    except Exception as e:
        raise e
