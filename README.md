# posh-winter

Helps keep your Windows Terminal and Oh My Posh settings consistent across different dev boxes.

## Build Oh My Posh Config

You can build different variants of the same config template by specifying "inserts" in the template (see samples in the `.\assets\omp.templates\` folder).

### Usage

```
Import-Module .\src\Build-OmpTheme
Build-OmpTheme P3RC3V4L ubuntu -Root .\assets\
```
