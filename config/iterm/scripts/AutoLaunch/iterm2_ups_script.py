#!/usr/bin/env python3
import iterm2
import asyncio

# --- Configuration ---
UPSC_CMD = "/opt/homebrew/bin/upsc"
UPS_TARGET = "river3@localhost"  # Your UPS target
# ---------------------

async def main(connection):
    # Helper functions for formatting
    def format_ups_status(status):
        """Format UPS status with appropriate icons"""
        status_map = {
            'OL': '🔌 OL',      # Online
            'OB': '🔋 OB',      # On Battery
            'LB': '🪫 LB',      # Low Battery
            'CHRG': '⚡ CHRG',  # Charging
            'DISCHRG': '📉 DISCHRG',  # Discharging
            'OVER': '⚠️ OVER',  # Overloaded
            'RB': '🔄 RB',      # Replace Battery
            'TEST': '🧪 TEST',  # Testing
            'ALARM': '🚨 ALARM' # Alarm
        }

        # Handle multiple status codes (space-separated)
        if ' ' in status:
            codes = status.split()
            formatted = [status_map.get(code, f"❓ {code}") for code in codes]
            return ' '.join(formatted)
        else:
            return status_map.get(status, f"❓ {status}")

    def format_battery_charge(charge):
        """Format battery charge with appropriate icon"""
        if charge == "ERR":
            return "🔋 ERR"
        try:
            level = int(float(charge))
            icon = "🪫" if level < 15 else "🔋"
            return f"{icon} {charge}%"
        except (ValueError, TypeError):
            return f"🔋 {charge}%"

    # Define the status bar component (knobs required even if empty)
    component = iterm2.StatusBarComponent(
        short_description="UPS Status",
        detailed_description="Shows status, charge, and runtime of a NUT-controlled UPS.",
        knobs=[],  # Empty knobs list - required parameter
        exemplar="UPS: 🔌 OL | 🔋 100% | ⏳ 15 min",
        identifier="com.google.iterm2.ups-status",
        update_cadence=60
    )

    # Main UPS status function
    @iterm2.StatusBarRPC
    async def ups_coroutine(knobs):
        try:
            # Run upsc command asynchronously
            proc = await asyncio.create_subprocess_exec(
                UPSC_CMD, UPS_TARGET,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                stdin=asyncio.subprocess.DEVNULL
            )

            # Get output with timeout
            stdout, stderr = await asyncio.wait_for(proc.communicate(), timeout=8.0)

            if proc.returncode != 0:
                return f"UPS: Connection Error ({UPS_TARGET})"

            output = stdout.decode().strip()
            if not output:
                return f"UPS: No Data ({UPS_TARGET})"

            # Parse UPS data
            status, charge, runtime = "ERR", "ERR", "ERR"

            for line in output.splitlines():
                if ': ' in line:
                    key, value = line.split(':', 1)
                    key, value = key.strip(), value.strip()

                    if key == 'ups.status':
                        status = value
                    elif key == 'battery.charge':
                        charge = value
                    elif key == 'battery.runtime':
                        try:
                            runtime_s = int(float(value))
                            runtime = str(runtime_s // 60)
                        except (ValueError, TypeError):
                            pass

            # Format and return result
            status_display = format_ups_status(status)
            charge_display = format_battery_charge(charge)

            return f"UPS: {status_display} | {charge_display} | ⏳ {runtime} min"

        except asyncio.TimeoutError:
            return f"UPS: Timeout ({UPS_TARGET})"
        except FileNotFoundError:
            return "UPS: upsc command not found"
        except Exception as e:
            return f"UPS: Error ({type(e).__name__})"

    # Register the component
    await component.async_register(connection, ups_coroutine)

# Run the script
iterm2.run_forever(main)
