#!/usr/bin/env python3

import iterm2
import asyncio
import os
import shutil

# --- Configuration ---
# Path to your upsc command
# Find upsc under either Homebrew prefix (Apple Silicon or Intel), then PATH
UPSC_CMD = shutil.which(
    "upsc", path=os.pathsep.join(["/opt/homebrew/bin", "/usr/local/bin", os.environ.get("PATH", "")])
) or "upsc"
# ---------------------

async def main(connection):
    # This defines a "knob," a setting you can edit in the iTerm2 GUI.
    knobs = [
        iterm2.StringKnob(
            "UPS Target",
            "e.g., myups@192.168.1.1", # Placeholder text
            "river3@localhost", # Default value
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
    async def ups_status_coroutine(knobs):
        ups_target = knobs.get("ups_target")
        if not ups_target:
            return "UPS: Not Configured"

        try:
            # Run the 'upsc' command to get all data at once.
            # Use an asyncio subprocess so a slow query doesn't block the event loop.
            proc = await asyncio.create_subprocess_exec(
                UPSC_CMD, ups_target,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                stdin=asyncio.subprocess.DEVNULL
            )
            try:
                stdout, _ = await asyncio.wait_for(proc.communicate(), timeout=5) # Prevent hangs.
            except asyncio.TimeoutError:
                proc.kill()
                await proc.wait()
                return f"UPS: Timeout ({ups_target})"
            if proc.returncode != 0:
                return f"UPS: Conn Err ({ups_target})"
            output = stdout.decode().strip()

            # Parse the output to find the values we need.
            status, charge, runtime = "ERR", "ERR", "ERR"
            for line in output.splitlines():
                if 'ups.status:' in line:
                    status = line.split(':')[1].strip()
                elif 'battery.charge:' in line:
                    charge = line.split(':')[1].strip()
                elif 'battery.runtime:' in line:
                    runtime_s = int(float(line.split(':')[1].strip()))
                    runtime = str(runtime_s // 60) # Convert to minutes

            return f"UPS: {status} | 🔋 {charge}% | ⏳ {runtime} min"

        except Exception:
            return "UPS: Script Error"

    # Register the component with iTerm2.
    await component.async_register(connection, ups_status_coroutine)

# This line tells iTerm2 to run our script.
iterm2.run_forever(main)
