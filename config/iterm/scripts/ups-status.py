#!/usr/bin/env python3

import iterm2
import asyncio
import subprocess

# --- Configuration ---
# Path to your upsc command
UPSC_CMD = "/opt/homebrew/bin/upsc"
# ---------------------

async def main(connection):
    # This defines a "knob," a setting you can edit in the iTerm2 GUI.
    knobs = [
        iterm2.StringKnob(
            "UPS Target",
            "river3@localhost", # Default value
            "e.g., myups@192.168.1.1", # Placeholder text
            "ups_target" # Key to access the value
        )
    ]

    # This defines the component that will appear in the status bar settings.
    # It includes the required 'knobs' and 'update_cadence' arguments.
    component = iterm2.StatusBarComponent(
        short_description="UPS Status",
        detailed_description="Shows status, charge, and runtime of a NUT-controlled UPS.",
        knobs=knobs,
        exemplar="UPS: OL | 🔋 100% | ⏳ 15 min",
        identifier="com.google.iterm2.ups-status.final", # Updated identifier
        update_cadence=60 # Set the update interval to 60 seconds.
    )

    # This function runs in the background to get the UPS status.
    @iterm2.StatusBarRPC
    async def ups_coroutine(knobs):
        ups_target = knobs.get("ups_target")
        if not ups_target:
            return "UPS: Not Configured"

        try:
            # Run the 'upsc' command to get all data at once.
            proc = subprocess.run(
                [UPSC_CMD, ups_target],
                capture_output=True,
                text=True,
                check=True,
                timeout=5 # Add a timeout to prevent hangs.
            )
            output = proc.stdout.strip()

            # Parse the output to find the values we need.
            status, charge, runtime = "ERR", "ERR", "ERR"
            for line in output.splitlines():
                if 'ups.status:' in line:
                    status = line.split(':')[1].strip()
                elif 'battery.charge:' in line:
                    charge = line.split(':')[1].strip()
                elif 'battery.runtime:' in line:
                    runtime_s = int(line.split(':')[1].strip())
                    runtime = str(runtime_s // 60) # Convert to minutes

            return f"UPS: {status} | 🔋 {charge}% | ⏳ {runtime} min"

        except subprocess.TimeoutExpired:
            return f"UPS: Timeout ({ups_target})"
        except subprocess.CalledProcessError:
            return f"UPS: Conn Err ({ups_target})"
        except Exception as e:
            return "UPS: Script Error"

    # Register the component with iTerm2.
    await component.async_register(connection, ups_coroutine)

# This line tells iTerm2 to run our script.
iterm2.run_forever(main)
