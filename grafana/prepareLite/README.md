Dashboard for streaming lite is prepared from standar streaming dashboard with a script which makes following changes:
- Removes `RocksDB` and `Scenario health` rows. It is __important__ that they are collapsed in saved streaming dashboard. Otherwise, the json 
  structure is different and it's harder to remove rows...
- Changes measurement names. Unfortunately, Flink separates measurement parts with `_`, while Dropwizard with `.`. 
- Changes `uid` and `title` fields.

TODO: handle slot/taskId