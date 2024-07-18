{
  inputs,
  lib,
  channels,
  ...
}:
final: prev: { gdtoolkit = channels.master.gdtoolkit_3; }
