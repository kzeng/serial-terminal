# Code Signing Policy

## Project

Serial Terminal is an open-source Flutter Windows serial terminal maintained
in the public repository:

https://github.com/kzeng/serial-terminal

The project is distributed under the MIT License. The source code, build
workflow, product documentation, and release history are public.

## What is signed

Windows executable and dynamic-library files produced by the GitHub Actions
Windows Release build are submitted to SignPath Foundation for Authenticode
signing. The signed files are used for the Windows release artifact.

## Build and signing process

1. Changes are committed to the public GitHub repository.
2. GitHub Actions builds the Windows Release output on a GitHub-hosted Windows
   runner and runs `flutter analyze` and `flutter test`.
3. The unsigned Release output is uploaded as a temporary GitHub Artifact.
4. The main-branch signing workflow submits that artifact to SignPath using the
   official SignPath GitHub Action.
5. SignPath applies the configured signing policy and returns the signed
   artifact.
6. The workflow verifies that the signed Windows executable is present before
   publishing the final build artifact.

Pull requests are never submitted for production signing. Signing is enabled
only after the required SignPath repository variables and API secret have been
configured.

## GitHub configuration

After SignPath Foundation approves the project, configure these repository
values under **Settings → Secrets and variables → Actions**:

Secret:

- `SIGNPATH_API_TOKEN`

Repository variables:

- `SIGNPATH_ORGANIZATION_ID`
- `SIGNPATH_PROJECT_SLUG`
- `SIGNPATH_SIGNING_POLICY_SLUG`
- `SIGNPATH_ARTIFACT_CONFIGURATION_SLUG` (if the SignPath project uses a
  non-default artifact configuration)

The workflow uses the official
`signpath/github-action-submit-signing-request@v3` action. The SignPath project
must be configured to Authenticode-sign the PE files in the uploaded Windows
Release artifact.

## Approval and release rules

- Source changes are reviewed through normal GitHub repository access controls.
- Only maintainers with release authority may merge release changes to `main`.
- A release must be built by GitHub Actions from the public repository.
- The signing request is made only from the main branch after the automated
  analysis and tests succeed.
- The signed output must be the artifact returned by SignPath; local unsigned
  replacement files are not accepted.

## Security

- SignPath Foundation retains the signing private key in its managed HSM.
- No signing private key or certificate password is stored in this repository.
- The SignPath API token is stored only as a GitHub Actions Secret.
- Suspected compromise, unexpected signing requests, or malicious changes are
  reported to SignPath and the repository maintainers immediately.

## User verification

Users should download releases only from the project GitHub repository and
verify the Windows executable's Digital Signatures tab. The signer shown by
SignPath Foundation identifies the signing service; it does not claim that
SignPath Foundation is the original author of Serial Terminal.
