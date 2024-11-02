"""
    Builder for S3C2410A platform
"""

import os

from SCons.Script import COMMAND_LINE_TARGETS, AlwaysBuild, Default, DefaultEnvironment

env = DefaultEnvironment()

env.Replace(
    _BINPREFIX="arm-none-eabi-",
    CC="${_BINPREFIX}gcc",
    LD="${_BINPREFIX}ld",
    AR="${_BINPREFIX}ar",
    AS="${_BINPREFIX}as",
    ASCOM="${_BINPREFIX}as",
    OBJCOPY="${_BINPREFIX}objcopy",
    OBJDUMP="${_BINPREFIX}objdump",
)

env.Append(
    ENV={"PATH": os.environ["PATH"]},
    CCFLAGS="-Og -march=armv4t",
    ASFLAGS="-Og -march=armv4t",
    LINKFLAGS="-nostdlib"
)

#
# Target: Build executable program
#

target_bin = env.BuildProgram()

#
# Target: Execute binary
#

exec_action = env.VerboseAction("$SOURCE $PROGRAM_ARGS", "Executing $SOURCE")

AlwaysBuild(env.Alias("exec", target_bin, exec_action))
AlwaysBuild(env.Alias("upload", target_bin, exec_action))

#
# Target: Print binary size
#

target_size = env.Alias(
    "size", target_bin, env.VerboseAction("$SIZEPRINTCMD", "Calculating size $SOURCE")
)
AlwaysBuild(target_size)

#
# Target: Define targets
#
Default(target_bin)
