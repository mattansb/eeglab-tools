# eeglab-tools

_Useful functions for EEGLAB workflow_

This is a collection of assorted MATLAB functions to be used along-side EEGLAB.

- `EventTypeConvertor` (v2 v3) are used to convert egi-mff files' events to something workable within EEGLAB.
    - `EventTypeConvertor2` should be used for `.mff` (v2) files imported with `pop_readegimff`.
    - `EventTypeConvertor3` should be used for `.mff` (v3) files imported with [`pop_mffimport`](https://github.com/arnodelorme/mffmatlabio).
- `fix_event_offset` fixes event offsets.
- `select_set` can be used to create a list of `.set` files (can also be used of any file extention).
- `spec_eegplot` useful for setting the time and amp scale in a call to `pop_eegplot` such as:
```Matlab
pop_eegplot(EEG, 1, 1, 1); spec_eegplot(40, 10);
```

