### About create-secrets tool

The create-secrets tool binary has been removed from the repo due to upstream package software issue.

Please install the NPM package version [here](https://www.npmjs.com/package/@magda/create-secrets).

```bash
npm install --global @magda/create-secrets
```

After the installation you should be able to run `create-secrets` command anywhere from your commandline:

```
$ create-secrets

magda-create-secrets tool version: x.xx.x
Found previous saved config (September 2nd 2020, 1:58:17 pm).
? Do you want to connect to kubernetes cluster to create secrets without going through any questions?
❯ NO (Going through all questions)
  YES (Create Secrets in Cluster using existing config now)
```
