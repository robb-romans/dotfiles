#!/usr/bin/env python3
import iterm2
import asyncio
import subprocess

# --- Configuration ---
# Path to your upsc command
UPSC_CMD = "/opt/homebrew/bin/upsc"
# Set to True to test without actually calling upsc
TEST_MODE = False
# ---------------------

async def main(connection):
    # Helper function to format UPS status with appropriate icons
    def format_ups_status(status):
        """Format UPS status with appropriate icons and colors"""
        status_map = {
            'OL': '🔌 OL',      # Online (plugged in)
            'OB': '🔋 OB',      # On Battery
            'LB': '🪫 LB',      # Low Battery
            'CAL': '⚙️ CAL',    # Calibrating
            'CHRG': '⚡ CHRG',  # Charging
            'DISCHRG': '📉 DISCHRG',  # Discharging
            'OVER': '⚠️ OVER',  # Overloaded
            'RB': '🔄 RB',      # Replace Battery
            'TEST': '🧪 TEST',  # Testing
            'FSD': '⏹️ FSD',    # Forced Shutdown
            'ALARM': '🚨 ALARM' # Alarm condition
        }
        
        # Handle multiple status codes (space-separated)
        if ' ' in status:
            codes = status.split()
            formatted_codes = []
            for code in codes:
                formatted_codes.append(status_map.get(code, f"❓ {code}"))
            return ' '.join(formatted_codes)
        else:
            return status_map.get(status, f"❓ {status}")
    
    def format_battery_charge(charge):
        """Format battery charge with appropriate battery icon"""
        if charge == "ERR":
            return "🔋 ERR"
        
        try:
            charge_level = int(float(charge))
            if charge_level >= 90:
                return f"🔋 {charge}%"      # Full battery
            elif charge_level >= 60:
                return f"🔋 {charge}%"      # High battery  
            elif charge_level >= 30:
                return f"🔋 {charge}%"      # Medium battery
            elif charge_level >= 15:
                return f"🪫 {charge}%"      # Low battery
            else:
                return f"🪫 {charge}%"      # Critical battery
        except (ValueError, TypeError):
            return f"🔋 {charge}%"
    # This defines a "knob," a setting you can edit in the iTerm2 GUI.
    knobs = [
        iterm2.StringKnob(
            "UPS Target",
            "Enter UPS target (e.g. ups@hostname)",  # Placeholder text
            "river3@localhost",  # Default value
            "ups_target"  # Key to access the value
        )
    ]
    
    # This defines the component that will appear in the status bar settings.
    # It includes the required 'knobs' and 'update_cadence' arguments.
    component = iterm2.StatusBarComponent(
        short_description="UPS Status",
        detailed_description="Shows status, charge, and runtime of a NUT-controlled UPS.",
        knobs=knobs,
        exemplar="UPS: 🔌 OL | 🔋 100% | ⏳ 15 min",
        identifier="com.google.iterm2.ups-status.final",  # Updated identifier
        update_cadence=60  # Set the update interval to 60 seconds.
    )
    
    # This function runs in the background to get the UPS status.
    @iterm2.StatusBarRPC
    async def ups_coroutine(knobs):
        # TEMPORARY: Force the correct target until iTerm2 knob issue is resolved
        ups_target = "river3@localhost"
        
        # Debug: Show what we're getting from knobs (uncomment to debug)
        # raw_target = knobs.get("ups_target", "river3@localhost")
        # if raw_target != ups_target:
        #     return f"UPS: iTerm2 sent '{raw_target}', using '{ups_target}'"
            
        # Test mode - return fake data to verify the script works
        if TEST_MODE:
            status_display = format_ups_status("OL")
            charge_display = format_battery_charge("85")
            return f"UPS: {status_display} | {charge_display} | ⏳ 45 min [TEST]"
            
        try:
            # Debug: Log the attempt
            import time
            start_time = time.time()
            
            # Set up environment and run the 'upsc' command with better error handling
            import os
            env = os.environ.copy()
            # Ensure PATH includes homebrew
            env['PATH'] = '/opt/homebrew/bin:/usr/local/bin:' + env.get('PATH', '')
            
            # Debug: Check if file exists
            if not os.path.exists(UPSC_CMD):
                return f"UPS: upsc missing at {UPSC_CMD}"
            
            # Use asyncio subprocess for better timeout handling
            proc = await asyncio.create_subprocess_exec(
                UPSC_CMD, ups_target,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                env=env,
                stdin=asyncio.subprocess.DEVNULL
            )
            
            # Wait for completion with timeout
            try:
                stdout, stderr = await asyncio.wait_for(proc.communicate(), timeout=8.0)
            except asyncio.TimeoutError:
                proc.kill()
                await proc.wait()
                return f"UPS: Async Timeout ({ups_target})"
            
            elapsed = time.time() - start_time
            
            if proc.returncode != 0:
                error_msg = stderr.decode().strip() if stderr else "Unknown error"
                return f"UPS: Cmd Err {proc.returncode} ({error_msg[:20]})"
            
            output = stdout.decode().strip()
            
            if not output:
                return f"UPS: No Data in {elapsed:.1f}s ({ups_target})"
            
            # Parse the output to find the values we need.
            status, charge, runtime = "ERR", "ERR", "ERR"
            
            for line in output.splitlines():
                line = line.strip()
                if ': ' in line:  # Ensure line has proper format
                    key, value = line.split(':', 1)
                    key = key.strip()
                    value = value.strip()
                    
                    if key == 'ups.status':
                        status = value
                    elif key == 'battery.charge':
                        charge = value
                    elif key == 'battery.runtime':
                        try:
                            runtime_s = int(float(value))
                            runtime = str(runtime_s // 60)  # Convert to minutes
                        except (ValueError, TypeError):
                            runtime = "ERR"
            
            # Format status with appropriate icons and indicators
            status_display = format_ups_status(status)
            charge_display = format_battery_charge(charge)
            
            return f"UPS: {status_display} | {charge_display} | ⏳ {runtime} min"
            
        except FileNotFoundError:
            return f"UPS: upsc not found"
        except PermissionError:
            return f"UPS: Permission denied"
        except Exception as e:
            return f"UPS: {type(e).__name__} ({str(e)[:15]})"
    
    # Register the component with iTerm2.
    await component.async_register(connection, ups_coroutine)

# This line tells iTerm2 to run our script.
iterm2.run_forever(main)