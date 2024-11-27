const PWD = import.meta.dirname;
const INCLUDE = `${PWD}/pwsh/Microsoft.PowerShell_profile.ps1`;
const DST = "C:/Users/ousttrue/Documents/PowerShell/Microsoft.PowerShell_profile.ps1";

// create ps1 if not exists
const file = Bun.file(DST);
if (!await file.exists()) {
  console.info(`write ${file.name}`);
  // https://bun.sh/guides/write-file/basic
  await Bun.write(DST, `. "${INCLUDE}"`);
}
