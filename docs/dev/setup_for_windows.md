# Setup development for Windows

> [!NOTE]
> This is only necessary for internal development. If you want to create a Starry project, simply download it from releases.

You need Python, [Just](https://github.com/casey/just), and [Odin](https://odin-lang.org/) dev-2026-09 installed and available from `PATH`.

You also need MSVC and the Windows SDK. The easiest way to download those is through the Visual Studio installer, with the "Desktop development with C++" option ticked.

- If you want the smallest install possible, you can try [this script](https://gist.github.com/mmozeiko/7f3162ec2988e81e56d5c4e22cde9977) instead.

Now you should be able to use the `just` command runner for development:

Examples:

```sh
just build-starry # build starry alone
just studio       # launch editor
just run-hello    # test one of the samples with run-*
just release      # prepares everything for release
```
