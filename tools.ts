// https://bun.sh/docs/runtime/shell
import { $ } from "bun";
import fs from "node:fs";

const args = Bun.argv.slice(2)
const GHQ_ROOT = (await $`ghq root`.text()).trim().replaceAll('\\', '/');

async function nvim_install(prefix: string) {
  // https://github.com/neovim/neovim/blob/master/BUILD.md#build-prerequisites
  await $`py -m pip install --upgrade pip`;
  await $`pip install cmake ninja`;

  // https://bun.sh/docs/runtime/shell
  const repos = "/github.com/neovim/neovim";
  const src = `${GHQ_ROOT}${repos}`;
  if (fs.existsSync(src)) {
    $.cwd(src);
    await $`git pull`;
    console.log('pull');
    if (fs.existsSync(`${src}/build`)) {
      await $`rm -rf .deps`;
      await $`rm -rf build`;
    }
  }
  else {
    console.log(`not exists: ${src}`);
    await $`ghq get https://github.com/neovim/neovim`;
    $.cwd(src);
  }

  // #git switch -c v0.10.1 tags/v0.10.1
  // # git switch v0.10.1

  await $`cmake -G Ninja -S cmake.deps -B .deps -DCMAKE_BUILD_TYPE=Release`
  await $`cmake --build .deps`
  await $`cmake -G Ninja -S . -B build -DCMAKE_BUILD_TYPE=Release`
  await $`cmake --build build`
  await $`cmake --install build --prefix ${prefix}`
}

for (const arg of args) {
  switch (arg) {
    case 'nvim':
      await nvim_install(`${process.env.USERPROFILE}/neovim`);
      break;

    default:
      console.warn(`unknown :${arg}`);
      break;
  }
}

// python

// neovim

// go(fzf, etc...)

// cargo(zoxide, etc...)

// zig https://github.com/marler8997/zigup
