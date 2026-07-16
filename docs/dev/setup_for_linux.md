# Setup development on Linux

> [!NOTE]
> This is only necessary for internal development. If you want to create a Starry project, simply download it from releases.

Required packages:

```sh
# debian/ubuntu
sudo apt install clang just libglfw3-dev
# fedora
sudo dnf install clang just libcxx-devel glfw-devel
# arch linux
sudo pacman -S clang just glfw
```

You also need [Odin](https://odin-lang.org/) dev-2026-07a (your package manager is likely out of date!)

Now you should be able to use the `just` command runner for development:

Examples:

```sh
just build-starry # build starry alone
just run-hello    # test one of the samples with run-*
just release      # prepares everything for release
```
