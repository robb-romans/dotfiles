#!/usr/bin/env python3
import iterm2

async def main(connection):
    component = iterm2.StatusBarComponent(
        short_description="Hello",
        detailed_description="A simple test component",
        exemplar="Hello World",
        identifier="com.google.iterm2.hello-world",
        update_cadence=None)

    @iterm2.StatusBarRPC
    async def hello_coro(knobs):
        return "Hello World!"

    await component.async_register(connection, hello_coro)

iterm2.run_forever(main)
