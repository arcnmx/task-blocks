## Install

Depends on bash and jq. Requires taskwarrior 2.3 or later.

```bash
make install TASKDATA=$HOME/.task

task config uda.blocks.type string
task config uda.blocks.label Blocks

task config uda.blocked.type string
task config uda.blocked.label Blocked
```

## Usage

The `blocks:` attribute is the inverse of `depends:`. `blocked:` is also
supported as an alternative to `depends:`.

```bash
task add sometask
task add blocks:sometask something else
task sometask modify blocks:something # okay circular dependencies don't work but modify does
```

## See Also

- https://gist.github.com/wbsch/a2f7264c6302918dfb30
- https://github.com/coddingtonbear/taskwarrior-blocks-capsule
